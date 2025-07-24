import 'package:flutter/material.dart';
import '../models/face_detection_result.dart';

class FaceOverlayWidget extends StatelessWidget {
  final List<FaceDetectionResult> faces;
  final Size imageSize;
  final Size screenSize;

  const FaceOverlayWidget({
    Key? key,
    required this.faces,
    required this.imageSize,
    required this.screenSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: FaceOverlayPainter(
        faces: faces,
        imageSize: imageSize,
        screenSize: screenSize,
      ),
      size: screenSize,
    );
  }
}

class FaceOverlayPainter extends CustomPainter {
  final List<FaceDetectionResult> faces;
  final Size imageSize;
  final Size screenSize;

  FaceOverlayPainter({
    required this.faces,
    required this.imageSize,
    required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (faces.isEmpty) return;

    // Calculate scale factors to map face coordinates to screen coordinates
    final scaleX = screenSize.width / imageSize.width;
    final scaleY = screenSize.height / imageSize.height;

    for (final face in faces) {
      _drawFaceBoundingBox(canvas, face, scaleX, scaleY);
      _drawFaceLandmarks(canvas, face, scaleX, scaleY);
      _drawFaceInfo(canvas, face, scaleX, scaleY);
    }
  }

  void _drawFaceBoundingBox(
    Canvas canvas,
    FaceDetectionResult face,
    double scaleX,
    double scaleY,
  ) {
    final paint = Paint()
      ..color = face.isWellPositioned ? Colors.green : Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final scaledRect = Rect.fromLTWH(
      face.boundingBox.left * scaleX,
      face.boundingBox.top * scaleY,
      face.boundingBox.width * scaleX,
      face.boundingBox.height * scaleY,
    );

    canvas.drawRect(scaledRect, paint);
  }

  void _drawFaceLandmarks(
    Canvas canvas,
    FaceDetectionResult face,
    double scaleX,
    double scaleY,
  ) {
    if (face.landmarks == null) return;

    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    for (final landmark in face.landmarks!) {
      final scaledPoint = Offset(
        landmark.dx * scaleX,
        landmark.dy * scaleY,
      );
      canvas.drawCircle(scaledPoint, 3.0, paint);
    }
  }

  void _drawFaceInfo(
    Canvas canvas,
    FaceDetectionResult face,
    double scaleX,
    double scaleY,
  ) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Prepare info text
    final confidence = (face.confidence * 100).toStringAsFixed(1);
    final status = face.isWellPositioned ? 'Good' : 'Poor';
    final info = 'Conf: $confidence%\nPos: $status';

    textPainter.text = TextSpan(
      text: info,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            offset: Offset(1, 1),
            blurRadius: 2,
            color: Colors.black,
          ),
        ],
      ),
    );

    textPainter.layout();

    // Position text above the face bounding box
    final textOffset = Offset(
      face.boundingBox.left * scaleX,
      (face.boundingBox.top * scaleY) - textPainter.height - 5,
    );

    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Always repaint when faces change
  }
}
