import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import '../models/accident_report.dart';
import '../services/location_service.dart';
import '../services/document_service.dart';
import '../services/local_storage_service.dart';
import '../models/client_case.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import '../widgets/emergency_button.dart';
import '../widgets/document_capture.dart';
import '../screens/review_photos_screen.dart';
import '../services/identity_service.dart';

class EmergencyResponseScreen extends StatefulWidget {
  const EmergencyResponseScreen({super.key});

  @override
  State<EmergencyResponseScreen> createState() => _EmergencyResponseScreenState();
}

class _EmergencyResponseScreenState extends State<EmergencyResponseScreen> {
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  bool _isRecording = false;
  String? _currentRecordingPath;
  final List<String> _capturedPhotos = [];
  final List<String> _audioRecordings = [];
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _injuryController = TextEditingController();
  final TextEditingController _witnessController = TextEditingController();
  final TextEditingController _policeReportController = TextEditingController();
  bool _emergencyServicesCalled = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _injuryController.dispose();
    _witnessController.dispose();
    _policeReportController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isLoadingLocation = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are turned off. Enable them and retry.')),
      );
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() => _isLoadingLocation = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission permanently denied. Open app settings to allow.')),
      );
      return;
    }

    final position = await LocationService.getCurrentLocation();
    setState(() {
      _currentPosition = position;
      _isLoadingLocation = false;
    });
  }

  Future<void> _capturePhoto() async {
    final photoPath = await DocumentService.capturePhoto();
    if (photoPath != null) {
      setState(() => _capturedPhotos.add(photoPath));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo captured successfully')),
      );
    }
  }

  Future<void> _toggleAudioRecording() async {
    if (_isRecording) {
      await DocumentService.stopAudioRecording();
      if (_currentRecordingPath != null) {
        setState(() {
          _audioRecordings.add(_currentRecordingPath!);
          _currentRecordingPath = null;
          _isRecording = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Audio recording saved')),
        );
      }
    } else {
      final recordingPath = await DocumentService.startAudioRecording();
      if (recordingPath != null) {
        setState(() {
          _currentRecordingPath = recordingPath;
          _isRecording = true;
        });
      }
    }
  }

  Future<void> _saveAccidentReport() async {
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide an accident description')),
      );
      return;
    }

    final report = AccidentReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      latitude: _currentPosition?.latitude,
      longitude: _currentPosition?.longitude,
      locationDescription: _currentPosition != null
          ? LocationService.formatCoordinates(
              _currentPosition!.latitude, _currentPosition!.longitude)
          : 'Location unavailable',
      photoUrls: _capturedPhotos,
      audioUrls: _audioRecordings,
      description: _descriptionController.text,
      witnesses: _witnessController.text.split('\n').where((w) => w.isNotEmpty).toList(),
      injuryDescription: _injuryController.text,
      emergencyServicesCalled: _emergencyServicesCalled,
      policeReportNumber: _policeReportController.text,
    );

    await LocalStorageService().saveAccidentReport(report);

    // Automatically create a new ClientCase for the accident
    final newCase = ClientCase(
      id: 'case_${report.id}',
      clientName:
          'New Client (Accident: ${report.timestamp.toLocal().toString().split(' ')[0]})',
      clientEmail: 'N/A',
      clientPhone: 'N/A',
      createdAt: DateTime.now(),
      status: CaseStatus.intake,
      accidentReportId: report.id,
      // Store raw file paths for user-owned media
      documents: <String>[...report.photoUrls, ...report.audioUrls],
      milestones: [
        CaseMilestone(
          title: 'Accident Reported',
          description: 'Initial accident report submitted via emergency response module.',
          completedDate: DateTime.now(),
          isCompleted: true,
        ),
      ],
      communications: const [],
      attorneyNotes: 'Automatically created from accident report.',
    );
    await LocalStorageService().saveClientCase(newCase);

    // Prepare email subject/body (always include lat/long when available)
    final coordsString = (report.latitude != null && report.longitude != null)
        ? LocationService.formatCoordinates(report.latitude!, report.longitude!)
        : 'Unavailable';
    final mapsLink = (report.latitude != null && report.longitude != null)
        ? 'https://maps.google.com/?q=${report.latitude},${report.longitude}'
        : 'N/A';

    final id = IdentityService.instance;
    final clientLine = [if (id.name != null) id.name, if (id.phone != null) id.phone, if (id.email != null) id.email]
        .whereType<String>()
        .where((s) => s.trim().isNotEmpty)
        .join(' • ');
    final subject = 'Accident Report ${report.id}${coordsString != 'Unavailable' ? ' – $coordsString' : ''}${clientLine.isNotEmpty ? ' – $clientLine' : ''}';
    final body = StringBuffer()
      ..writeln('To: joe@bizooma.com')
      ..writeln('App: Win With CASEY')
      ..writeln('User ID: ${id.userId}')
      ..writeln('Client: ${clientLine.isNotEmpty ? clientLine : 'N/A'}')
      ..writeln('Accident Report ID: ${report.id}')
      ..writeln('Time: ${report.timestamp.toLocal()}')
      ..writeln('Coordinates: $coordsString')
      ..writeln('Maps: $mapsLink')
      ..writeln('Description: ${report.description}')
      ..writeln('Injuries: ${report.injuryDescription}')
      ..writeln('Witnesses: ${report.witnesses.join(', ')}')
      ..writeln('Police Report #: ${report.policeReportNumber}')
      ..writeln('Emergency services called: ${report.emergencyServicesCalled ? 'Yes' : 'No'}');

    // Copy Joe's email to clipboard to help ensure it's pasted into the composer
    await Clipboard.setData(const ClipboardData(text: 'joe@bizooma.com'));

    // Create a zip of captured media (photos + audio) and present share sheet for email
    final mediaToZip = <String>[..._capturedPhotos, ..._audioRecordings];
    if (mediaToZip.isNotEmpty) {
      final zipPath = await DocumentService.zipFiles(mediaToZip, zipNamePrefix: 'accident_media');
      if (zipPath != null) {
        await Share.shareXFiles(
          [XFile(zipPath, mimeType: 'application/zip')],
          subject: subject,
          text:
              '${body.toString()}\n\nA ZIP file with photos${_audioRecordings.isNotEmpty ? ' and audio notes' : ''} is attached. If the To field is empty, paste joe@bizooma.com.',
        );
      } else {
        // Fallback to details-only if zipping failed
        await Share.share(
          '${body.toString()}\n\nMedia ZIP could not be created. Sending details only.',
          subject: subject,
        );
      }
    } else {
      // No media captured: share details-only email
      await Share.share(
        '${body.toString()}\n\nNo media attached.',
        subject: subject,
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Accident report prepared. Email to joe@bizooma.com.')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Response'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emergency Services Section
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency Services',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: EmergencyButton(
                            label: '911',
                            subtitle: 'Emergency',
                            icon: Icons.local_hospital,
                            onPressed: () => _callEmergencyService('911'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: EmergencyButton(
                            label: 'Police',
                            subtitle: 'Non-Emergency',
                            icon: Icons.local_police,
                            onPressed: () => _callEmergencyService('police'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      value: _emergencyServicesCalled,
                      onChanged: (value) => setState(() => _emergencyServicesCalled = value ?? false),
                      title: const Text('Emergency services have been called'),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Location Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on),
                        const SizedBox(width: 8),
                        Text(
                          'Accident Location',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_isLoadingLocation)
                      const Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Getting location...'),
                        ],
                      )
                    else if (_currentPosition != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Coordinates: ${LocationService.formatCoordinates(
                              _currentPosition!.latitude, 
                              _currentPosition!.longitude
                            )}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Accuracy: ±${_currentPosition!.accuracy.toStringAsFixed(1)}m',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          const Text('Location unavailable'),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _getCurrentLocation,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Documentation Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Document the Scene',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    DocumentCaptureWidget(
                      onPhotoTaken: (path) => setState(() => _capturedPhotos.add(path)),
                      onAudioRecorded: (path) => setState(() => _audioRecordings.add(path)),
                      photoCount: _capturedPhotos.length,
                      audioCount: _audioRecordings.length,
                      isRecording: _isRecording,
                      onToggleRecording: _toggleAudioRecording,
                    ),
                    const SizedBox(height: 12),
                    if (_capturedPhotos.isNotEmpty)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final updated = await Navigator.of(context).push<List<String>>(
                              MaterialPageRoute(
                                builder: (_) => ReviewPhotosScreen(initialPhotos: _capturedPhotos),
                              ),
                            );
                            if (updated != null) {
                              setState(() {
                                _capturedPhotos
                                  ..clear()
                                  ..addAll(updated);
                              });
                            }
                          },
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Review Photos'),
                        ),
                      ),
                    if (_capturedPhotos.isNotEmpty)
                      _PhotoThumbGrid(
                        photos: _capturedPhotos,
                        onTap: _showPhotoViewer,
                        onDelete: (path) => setState(() => _capturedPhotos.remove(path)),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Description Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Accident Details',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Accident Description *',
                        hintText: 'Describe what happened...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _injuryController,
                      decoration: const InputDecoration(
                        labelText: 'Injury Description',
                        hintText: 'Describe any injuries...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _witnessController,
                      decoration: const InputDecoration(
                        labelText: 'Witness Information',
                        hintText: 'Names, phone numbers (one per line)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _policeReportController,
                      decoration: const InputDecoration(
                        labelText: 'Police Report Number',
                        hintText: 'If available',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveAccidentReport,
                icon: const Icon(Icons.save),
                label: const Text('SAVE ACCIDENT REPORT'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _callEmergencyService(String service) {
    // In a real app, this would use url_launcher to make phone calls
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Calling $service...')),
    );
  }

  void _showPhotoViewer(String path) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                child: Image.file(
                  File(path),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoThumbGrid extends StatelessWidget {
  final List<String> photos;
  final void Function(String path) onTap;
  final void Function(String path) onDelete;

  const _PhotoThumbGrid({
    required this.photos,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: photos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final path = photos[index];
        return GestureDetector(
          onTap: () => onTap(path),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.file(
                  File(path),
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 2,
                right: 2,
                child: InkWell(
                  onTap: () => onDelete(path),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: const Icon(Icons.close, size: 16, color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}