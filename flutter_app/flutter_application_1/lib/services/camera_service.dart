import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class CameraService extends ChangeNotifier {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  String? _error;

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  List<CameraDescription> get cameras => _cameras;

  Future<bool> initializeCamera() async {
    try {
      _error = null;

      // Get available cameras
      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        _error = 'No cameras available';
        notifyListeners();
        return false;
      }

      // Use front camera for face recognition (index 1), fallback to back camera
      CameraDescription selectedCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras.first,
      );

      // Initialize camera controller
      _controller = CameraController(
        selectedCamera,
        ResolutionPreset.medium, // Good balance of quality and performance
        enableAudio: false, // We don't need audio for face recognition
        imageFormatGroup: ImageFormatGroup.yuv420, // Good for ML processing
      );

      await _controller!.initialize();
      _isInitialized = true;

      if (kDebugMode) {
        print('✅ Camera initialized successfully');
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to initialize camera: $e';
      _isInitialized = false;
      if (kDebugMode) {
        print('❌ Camera initialization failed: $e');
      }
      notifyListeners();
      return false;
    }
  }

  Future<void> disposeCamera() async {
    try {
      await _controller?.dispose();
      _controller = null;
      _isInitialized = false;
      if (kDebugMode) {
        print('✅ Camera disposed successfully');
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error disposing camera: $e');
      }
    }
  }

  Future<XFile?> takePicture() async {
    if (!_isInitialized || _controller == null) {
      _error = 'Camera not initialized';
      notifyListeners();
      return null;
    }

    try {
      final XFile picture = await _controller!.takePicture();
      if (kDebugMode) {
        print('✅ Picture taken: ${picture.path}');
      }
      return picture;
    } catch (e) {
      _error = 'Failed to take picture: $e';
        if (kDebugMode) {
          print('❌ Failed to take picture: $e');
        }
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
