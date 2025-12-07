import 'package:flutter/material.dart';
import '../services/document_service.dart';
import './camera_capture_screen.dart';

class DocumentCaptureWidget extends StatelessWidget {
  final Function(String) onPhotoTaken;
  final Function(String) onAudioRecorded;
  final int photoCount;
  final int audioCount;
  final bool isRecording;
  final VoidCallback onToggleRecording;

  const DocumentCaptureWidget({
    super.key,
    required this.onPhotoTaken,
    required this.onAudioRecorded,
    required this.photoCount,
    required this.audioCount,
    required this.isRecording,
    required this.onToggleRecording,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Photo Capture Section
        Row(
          children: [
            Expanded(
              child: _DocumentCaptureButton(
                icon: Icons.camera_alt,
                label: 'Take Photo',
                subtitle: '$photoCount photos',
                onPressed: () => _takePhoto(context),
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DocumentCaptureButton(
                icon: isRecording ? Icons.stop : Icons.mic,
                label: isRecording ? 'Stop Recording' : 'Record Audio',
                subtitle: '$audioCount recordings',
                onPressed: onToggleRecording,
                color: isRecording ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
        
        if (isRecording) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Recording in progress...',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 16),

        // Documentation Tips
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 20,
                    color: Colors.blue[700],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Documentation Tips',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _TipText('Take photos from multiple angles'),
              _TipText('Include wide shots and close-ups of damage'),
              _TipText('Record witness statements and contact info'),
              _TipText('Capture road conditions and traffic signals'),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _takePhoto(BuildContext context) async {
    try {
      final result = await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CameraCaptureScreen()),
      );
      if (result is String) {
        onPhotoTaken(result);
      } else if (result is List<String>) {
        for (final path in result) {
          onPhotoTaken(path);
        }
      } else if (result == null) {
        // User backed out; no-op
      } else {
        // Unexpected type -> fallback to single capture
        final photoPath = await DocumentService.capturePhoto();
        if (photoPath != null) onPhotoTaken(photoPath);
      }
    } catch (_) {
      // Fallback to direct capture if navigation/camera screen fails
      final photoPath = await DocumentService.capturePhoto();
      if (photoPath != null) onPhotoTaken(photoPath);
    }
  }
}

class _DocumentCaptureButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onPressed;
  final Color color;

  const _DocumentCaptureButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.1),
          foregroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: BorderSide(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: color.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _TipText extends StatelessWidget {
  final String text;

  const _TipText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 8),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.blue[700],
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}