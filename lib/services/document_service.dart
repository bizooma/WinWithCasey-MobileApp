import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import '../models/document.dart';
import 'package:archive/archive.dart';

class DocumentService {
  static List<CameraDescription> _cameras = const [];
  static final AudioRecorder _audioRecorder = AudioRecorder();

  static Future<void> initializeCameras() async {
    try {
      _cameras = await availableCameras();
    } catch (e) {
      _cameras = const [];
    }
  }

  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status == PermissionStatus.granted;
  }

  static Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  static Future<String?> capturePhoto() async {
    if (!await requestCameraPermission()) return null;
    if (_cameras.isEmpty) {
      await initializeCameras();
      if (_cameras.isEmpty) return null;
    }

    CameraController? controller;
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '${directory.path}/$fileName';

      controller = CameraController(
        _cameras[0],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();
      if (controller.value.isTakingPicture) {
        // Small delay to avoid re-entrancy in rare cases
        await Future.delayed(const Duration(milliseconds: 120));
      }
      final XFile photo = await controller.takePicture();

      // Copy to our documents directory
      await photo.saveTo(filePath);
      return filePath;
    } catch (e) {
      // Log error for diagnosis in debug console
      // ignore: avoid_print
      print('DocumentService.capturePhoto error: $e');
      return null;
    } finally {
      try {
        // Ensure controller is disposed to release the camera resource
        await controller?.dispose();
      } catch (_) {}
    }
  }

  static Future<String?> startAudioRecording() async {
    if (!await requestMicrophonePermission()) return null;

    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        final filePath = '${directory.path}/$fileName';

        await _audioRecorder.start(
          const RecordConfig(),
          path: filePath,
        );
        return filePath;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  static Future<void> stopAudioRecording() async {
    try {
      await _audioRecorder.stop();
    } catch (e) {
      // Handle error
    }
  }

  static Future<bool> isRecording() async => await _audioRecorder.isRecording();

  static Future<String> getApplicationDocumentsPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<Document> createDocumentFromFile(
    String filePath,
    String name,
    DocumentType type,
    String description,
  ) async {
    final file = File(filePath);
    final fileStats = await file.stat();

    return Document(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      type: type,
      filePath: filePath,
      createdAt: DateTime.now(),
      description: description,
      fileSize: fileStats.size,
    );
  }

  static Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Handle error
    }
  }

  static String getFileExtension(String filePath) => filePath.split('.').last.toLowerCase();

  static bool isImageFile(String filePath) {
    final extension = getFileExtension(filePath);
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(extension);
  }

  static bool isAudioFile(String filePath) {
    final extension = getFileExtension(filePath);
    return ['mp3', 'wav', 'm4a', 'aac', 'ogg'].contains(extension);
  }

  // Create a zip file from provided file paths and return the zip path
  static Future<String?> zipFiles(List<String> filePaths, {String zipNamePrefix = 'accident_photos'}) async {
    if (filePaths.isEmpty) return null;
    try {
      final archive = Archive();
      for (final path in filePaths) {
        final file = File(path);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final filename = path.split('/').last;
          archive.addFile(ArchiveFile(filename, bytes.length, bytes));
        }
      }
      final zipBytes = ZipEncoder().encode(archive);
      if (zipBytes == null) return null;
      final dir = await getApplicationDocumentsDirectory();
      final zipPath = '${dir.path}/${zipNamePrefix}_${DateTime.now().millisecondsSinceEpoch}.zip';
      final zipFile = File(zipPath);
      await zipFile.writeAsBytes(zipBytes, flush: true);
      return zipPath;
    } catch (e) {
      return null;
    }
  }
}