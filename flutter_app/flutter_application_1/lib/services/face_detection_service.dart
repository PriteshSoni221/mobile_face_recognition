import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart'; // Updated import
import 'package:camera/camera.dart';
import '../models/face_detection_result.dart';

class FaceDetectionService {
  static FaceDetector? _faceDetector;

  // Initialize face detector with optimized settings
  static Future<void> initialize() async {
    if (_faceDetector != null) return;

    final options = FaceDetectorOptions(
      enableContours: false,
      enableLandmarks: true,
      enableClassification: false,
      enableTracking: false,
      minFaceSize: 0.1,
      performanceMode: FaceDetectorMode.fast,
    );

    _faceDetector = FaceDetector(options: options);

    if (kDebugMode) {
      print('✅ Face detector initialized');
    }
  }

  // Clean up resources
  static Future<void> dispose() async {
    await _faceDetector?.close();
    _faceDetector = null;

    if (kDebugMode) {
      print('✅ Face detector disposed');
    }
  }

  // Simplified: Detect faces from file path only (remove camera image for now)
  static Future<List<FaceDetectionResult>> detectFromImagePath(
    String imagePath,
  ) async {
    if (_faceDetector == null) {
      await initialize();
    }

    try {
      if (kDebugMode) {
        print('🔍 Detecting faces from: $imagePath');
      }

      final inputImage = InputImage.fromFilePath(imagePath);
      final faces = await _faceDetector!.processImage(inputImage);

      if (kDebugMode) {
        print('✅ Detected ${faces.length} faces');
      }

      return faces.map((face) => _convertToFaceDetectionResult(face)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Face detection from file failed: $e');
      }
      return [];
    }
  }

  // Convert ML Kit Face to our FaceDetectionResult
  static FaceDetectionResult _convertToFaceDetectionResult(Face face) {
    // Extract landmarks if available
    List<Offset>? landmarks;
    if (face.landmarks.isNotEmpty) {
      landmarks = face.landmarks.values
          .where((landmark) => landmark != null)
          .map((landmark) => Offset(
                landmark!.position.x.toDouble(),
                landmark.position.y.toDouble(),
              ))
          .toList();
    }

    return FaceDetectionResult(
      boundingBox: face.boundingBox,
      confidence: 1.0, // ML Kit doesn't provide confidence, assume 1.0
      landmarks: landmarks,
      headEulerAngleY: face.headEulerAngleY,
      headEulerAngleZ: face.headEulerAngleZ,
    );
  }
}
