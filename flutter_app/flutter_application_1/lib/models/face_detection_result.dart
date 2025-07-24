import 'dart:ui';

class FaceDetectionResult {
  final Rect boundingBox;
  final double confidence;
  final List<Offset>? landmarks;
  final double? headEulerAngleY; // Head rotation
  final double? headEulerAngleZ; // Head tilt

  const FaceDetectionResult({
    required this.boundingBox,
    required this.confidence,
    this.landmarks,
    this.headEulerAngleY,
    this.headEulerAngleZ,
  });

  // Check if face is well-positioned for recognition
  bool get isWellPositioned {
    // Face should be reasonably large (at least 100x100 pixels)
    if (boundingBox.width < 100 || boundingBox.height < 100) {
      return false;
    }

    // Head rotation shouldn't be too extreme
    if (headEulerAngleY != null && headEulerAngleY!.abs() > 30) {
      return false;
    }

    if (headEulerAngleZ != null && headEulerAngleZ!.abs() > 30) {
      return false;
    }

    return confidence > 0.7;
  }

  @override
  String toString() {
    return 'FaceDetectionResult(bbox: $boundingBox, confidence: $confidence, positioned: $isWellPositioned)';
  }
}
