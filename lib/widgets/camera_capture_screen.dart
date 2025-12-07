import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = const [];
  bool _initializing = true;
  String? _error;
  int _cameraIndex = 0;
  final List<String> _sessionPhotos = [];
  bool _saving = false;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  Future<void> _init() async {
    try {
      final camStatus = await Permission.camera.request();
      if (camStatus != PermissionStatus.granted) {
        setState(() {
          _error = 'Camera permission denied';
          _initializing = false;
        });
        return;
      }

      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _error = 'No cameras available';
          _initializing = false;
        });
        return;
      }

      await _startController(_cameraIndex);
    } catch (e) {
      setState(() {
        _error = 'Failed to initialize camera';
        _initializing = false;
      });
    }
  }

  Future<void> _startController(int index) async {
    try {
      final controller = CameraController(
        _cameras[index],
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) return;
      setState(() {
        _controller?.dispose();
        _controller = controller;
        _initializing = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _error = 'Failed to initialize camera: $e';
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !_controller!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize on resume
      setState(() => _initializing = true);
      _startController(_cameraIndex);
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    final next = (_cameraIndex + 1) % _cameras.length;
    setState(() => _initializing = true);
    _cameraIndex = next;
    await _startController(_cameraIndex);
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.isTakingPicture || _isCapturing) return;
    try {
      setState(() => _isCapturing = true);
      final xfile = await controller.takePicture();
      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savePath = '${dir.path}/$fileName';
      await xfile.saveTo(savePath);
      if (!mounted) return;
      setState(() {
        _sessionPhotos.add(savePath);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to capture photo: $e')),
      );
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

   void _removeAt(int index) {
     if (index < 0 || index >= _sessionPhotos.length) return;
     setState(() {
       _sessionPhotos.removeAt(index);
     });
   }

  Future<void> _finish() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      // Return all captured photos in this session
      if (!mounted) return;
      Navigator.of(context).pop<List<String>>(_sessionPhotos);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Capture Photos'),
        actions: [
          if (_sessionPhotos.isNotEmpty)
            TextButton(
              onPressed: _finish,
              child: Row(
                children: [
                  const Icon(Icons.check, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    'Done (${_sessionPhotos.length})',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          if (_cameras.length > 1)
            IconButton(
              icon: const Icon(Icons.cameraswitch),
              onPressed: _switchCamera,
              color: Colors.white,
            ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: _initializing
                  ? const Center(child: CircularProgressIndicator())
                  : (_error != null)
                      ? Center(
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.white),
                          ),
                        )
                      : (_controller != null && _controller!.value.isInitialized)
                          ? CameraPreview(_controller!)
                          : const SizedBox.shrink(),
            ),
            // Bottom capture controls and thumbnail tray
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_sessionPhotos.isNotEmpty)
                      Container(
                        height: 80,
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _sessionPhotos.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final path = _sessionPhotos[index];
                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    // ignore: deprecated_member_use
                                    // Using File here as photos are saved locally
                                    File(path),
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: InkWell(
                                    onTap: () => _removeAt(index),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.5),
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(Icons.close, size: 16, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(18),
                            ),
                            onPressed: _capture,
                            child: const Icon(Icons.camera_alt, size: 28),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
