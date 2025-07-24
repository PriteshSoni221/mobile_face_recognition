import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../services/camera_service.dart';
import '../widgets/camera_preview_widget.dart';
import '../utils/permission_helper.dart';

class CameraTestScreen extends StatefulWidget {
  @override
  State<CameraTestScreen> createState() => _CameraTestScreenState();
}

class _CameraTestScreenState extends State<CameraTestScreen> {
  bool _hasPermission = false;
  bool _checkingPermission = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final hasPermission = await PermissionHelper.hasCameraPermission();

    if (!hasPermission) {
      final granted = await PermissionHelper.requestCameraPermission();
      setState(() {
        _hasPermission = granted;
        _checkingPermission = false;
      });
    } else {
      setState(() {
        _hasPermission = true;
        _checkingPermission = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Test'),
        backgroundColor: Colors.blue,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_checkingPermission) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Checking camera permissions...'),
          ],
        ),
      );
    }

    if (!_hasPermission) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Camera Permission Required',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please grant camera permission to use face recognition',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _checkPermissions,
              child: Text('Grant Permission'),
            ),
          ],
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => CameraService(),
      child: CameraPreviewWidget(
        onPictureTaken: (XFile picture) {
          _showPictureDialog(picture);
        },
      ),
    );
  }

  void _showPictureDialog(XFile picture) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Picture Taken'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Picture saved successfully!'),
            SizedBox(height: 8),
            Text(
              'Path: ${picture.path}',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
