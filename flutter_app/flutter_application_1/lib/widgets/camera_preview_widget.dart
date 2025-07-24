import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../services/camera_service.dart';

class CameraPreviewWidget extends StatefulWidget {
  final Function(XFile)? onPictureTaken;
  final Widget? overlayWidget;

  const CameraPreviewWidget({
    super.key,
    this.onPictureTaken,
    this.overlayWidget,
  });

  @override
  State<CameraPreviewWidget> createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCamera();
    });
  }

  Future<void> _initializeCamera() async {
    final cameraService = context.read<CameraService>();
    await cameraService.initializeCamera();
  }

  @override
  void dispose() {
    final cameraService = context.read<CameraService>();
    cameraService.disposeCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CameraService>(
      builder: (context, cameraService, child) {
        // Show error if any
        if (cameraService.error != null) {
          return _buildErrorWidget(cameraService.error!);
        }

        // Show loading while initializing
        if (!cameraService.isInitialized || cameraService.controller == null) {
          return _buildLoadingWidget();
        }

        // Show camera preview
        return _buildCameraPreview(cameraService);
      },
    );
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            SizedBox(height: 16),
            const Text(
              'Camera Error',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                error,
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<CameraService>().clearError();
                _initializeCamera();
              },
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Initializing Camera...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview(CameraService cameraService) {
    return Stack(
      children: [
        // Camera preview
        Positioned.fill(
          child: AspectRatio(
            aspectRatio: cameraService.controller!.value.aspectRatio,
            child: CameraPreview(cameraService.controller!),
          ),
        ),

        // Custom overlay (for face detection visualization)
        if (widget.overlayWidget != null)
          Positioned.fill(child: widget.overlayWidget!),

        // Capture button
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: Center(
            child: _buildCaptureButton(cameraService),
          ),
        ),
      ],
    );
  }

  Widget _buildCaptureButton(CameraService cameraService) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: () async {
          final picture = await cameraService.takePicture();
          if (picture != null && widget.onPictureTaken != null) {
            widget.onPictureTaken!(picture);
          }
        },
        icon: Icon(
          Icons.camera_alt,
          color: Colors.black,
          size: 32,
        ),
      ),
    );
  }
}
