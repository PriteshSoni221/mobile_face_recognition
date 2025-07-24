import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../services/camera_service.dart';
import '../services/face_detection_service.dart';
import '../widgets/camera_preview_widget.dart';
import '../widgets/image_source_selector.dart';
import '../models/face_detection_result.dart';
import '../utils/permission_helper.dart';

class FaceDetectionTestScreen extends StatefulWidget {
  const FaceDetectionTestScreen({Key? key}) : super(key: key);

  @override
  State<FaceDetectionTestScreen> createState() =>
      _FaceDetectionTestScreenState();
}

class _FaceDetectionTestScreenState extends State<FaceDetectionTestScreen> {
  bool _hasPermission = false;
  bool _checkingPermission = true;
  bool _isDetecting = false;
  String _statusMessage = 'Ready to detect faces';
  XFile? _selectedImage;
  List<FaceDetectionResult> _detectedFaces = [];

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  @override
  void dispose() {
    FaceDetectionService.dispose();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    setState(() {
      _statusMessage = 'Checking permissions...';
    });

    // For simulator, we can skip camera permission and just use gallery
    final hasPermission = await PermissionHelper.hasCameraPermission();

    setState(() {
      _hasPermission = hasPermission;
      _checkingPermission = false;
      _statusMessage = hasPermission
          ? 'Ready - Camera and Gallery available'
          : 'Ready - Gallery available (simulator mode)';
    });

    // Initialize face detection
    try {
      await FaceDetectionService.initialize();
      setState(() {
        _statusMessage = _hasPermission
            ? 'Face detection ready - Camera and Gallery available'
            : 'Face detection ready - Gallery available (simulator mode)';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Face detection setup failed: $e';
      });
    }
  }

  void _showImageSourceSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ImageSourceSelector(
        showCamera: _hasPermission, // Only show camera if permission granted
        onImageSelected: _handleImageSelected,
      ),
    );
  }

  Future<void> _handleImageSelected(XFile image) async {
    setState(() {
      _selectedImage = image;
      _detectedFaces = [];
    });

    await _detectFacesFromImage(image);
  }

  Future<void> _detectFacesFromImage(XFile image) async {
    if (_isDetecting) return;

    setState(() {
      _isDetecting = true;
      _statusMessage = 'Detecting faces...';
    });

    try {
      final faces = await FaceDetectionService.detectFromImagePath(image.path);

      setState(() {
        _detectedFaces = faces;
        _statusMessage = 'Found ${faces.length} face(s) in selected image';
      });

      _showDetectionResults(faces, image.path);
    } catch (e) {
      setState(() {
        _statusMessage = 'Detection failed: $e';
        _detectedFaces = [];
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Face detection failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isDetecting = false;
      });
    }
  }

  void _showDetectionResults(
      List<FaceDetectionResult> faces, String imagePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detection Results'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Found ${faces.length} face(s)'),
              const SizedBox(height: 8),
              if (faces.isNotEmpty) ...[
                const Text('Details:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                ...faces.asMap().entries.map((entry) {
                  final index = entry.key;
                  final face = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: face.isWellPositioned
                            ? Colors.green.shade50
                            : Colors.orange.shade50,
                        border: Border.all(
                          color: face.isWellPositioned
                              ? Colors.green
                              : Colors.orange,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Face ${index + 1}:',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                              'Position: ${face.isWellPositioned ? "Good ✅" : "Poor ⚠️"}'),
                          Text(
                              'Size: ${face.boundingBox.width.toInt()}×${face.boundingBox.height.toInt()}px'),
                          Text(
                              'Confidence: ${(face.confidence * 100).toStringAsFixed(1)}%'),
                          if (face.headEulerAngleY != null)
                            Text(
                                'Head rotation: ${face.headEulerAngleY!.toStringAsFixed(1)}°'),
                        ],
                      ),
                    ),
                  );
                }),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                      'No faces detected. Try:\n• Different photo\n• Better lighting in photo\n• Face more visible'),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (faces.isNotEmpty)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Next step - ONNX processing
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Next: ONNX embedding extraction!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Process with ONNX'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Detection Test'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            onPressed: _showImageSourceSelector,
            icon: const Icon(Icons.add_photo_alternate),
            tooltip: 'Select Image',
          ),
        ],
      ),
      body: Column(
        children: [
          // Status bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.green.shade50,
            child: Row(
              children: [
                if (_isDetecting)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _statusMessage,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showImageSourceSelector,
        icon: const Icon(Icons.add_photo_alternate),
        label: const Text('Select Image'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildMainContent() {
    if (_checkingPermission) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Setting up face detection...'),
          ],
        ),
      );
    }

    if (_selectedImage != null) {
      return _buildImagePreview();
    }

    return _buildWelcomeScreen();
  }

  Widget _buildImagePreview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Image preview
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 400),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(_selectedImage!.path),
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Detection results summary
          if (_detectedFaces.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border.all(color: Colors.blue.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detection Summary',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Faces found: ${_detectedFaces.length}'),
                  Text(
                      'Well positioned: ${_detectedFaces.where((f) => f.isWellPositioned).length}'),
                  if (_detectedFaces.any((f) => f.isWellPositioned))
                    const Text('✅ Ready for face recognition!',
                        style: TextStyle(
                            color: Colors.green, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showImageSourceSelector,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Another'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _detectedFaces.isNotEmpty
                      ? () => _showDetectionResults(
                          _detectedFaces, _selectedImage!.path)
                      : null,
                  icon: const Icon(Icons.info),
                  label: const Text('View Details'),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.face_retouching_natural,
            size: 100,
            color: Colors.green.shade300,
          ),
          const SizedBox(height: 24),
          const Text(
            'Face Detection Test',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Select an image to test face detection',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _showImageSourceSelector,
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('Select Image'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
          const SizedBox(height: 16),
          if (!_hasPermission)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border.all(color: Colors.orange.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Running in simulator mode - Gallery only',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
