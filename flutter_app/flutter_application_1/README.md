# Mobile Face Recognition Flutter App

A Flutter mobile application for face recognition using ONNX Runtime and Google ML Kit.

## Features

- **Face Detection**: Google ML Kit for accurate face detection
- **Face Recognition**: ONNX Runtime integration with MobileFaceNet model
- **Gallery & Camera Support**: Process images from camera or photo library
- **Real-time Processing**: Optimized for mobile performance
- **User Management**: Register and recognize users with face embeddings

## Architecture

- **Face Detection**: Google ML Kit Face Detection
- **Face Recognition**: ONNX Runtime with MobileFaceNet model
- **Image Processing**: Custom preprocessing pipeline
- **Database**: SQLite for user storage
- **State Management**: Provider pattern

## Setup

### Prerequisites

- Flutter SDK (3.0+)
- Android Studio / Xcode
- Android device/emulator or iOS simulator

### Installation

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Add model files to assets**
   - Place `mobilefacenet_mobile.onnx` in `assets/models/`
   - Place `mobile_config.json` in `assets/models/`

3. **Run the app**
   ```bash
   # For Android
   flutter run -d android
   
   # For iOS
   flutter run -d ios
   
   # For simulator
   flutter run
   ```

## Usage

### Testing Face Detection

1. Launch the app
2. Tap "Test Face Detection"
3. Select image from gallery or take photo
4. View detection results with face analysis

### Testing ONNX Integration

1. Go to Face Detection Test
2. Select an image with a clear face
3. Tap "Process Face X with ONNX"
4. View extracted face embeddings

## Key Dependencies

```yaml
dependencies:
  camera: ^0.10.5+5                    # Camera access
  google_mlkit_face_detection: ^0.9.0  # Face detection
  onnxruntime: ^1.4.1                  # ONNX model inference
  image_picker: ^1.0.4                 # Gallery access
  sqflite: ^2.3.0                      # Local database
  provider: ^6.0.5                     # State management
```

## Project Structure

```
lib/
├── main.dart                        # App entry point
├── screens/                         # UI screens
│   ├── camera_test_screen.dart
│   └── face_detection_test_screen.dart
├── services/                        # Core services
│   ├── camera_service.dart
│   ├── face_detection_service.dart
│   └── face_recognition_service.dart
├── models/                          # Data models
│   ├── face_detection_result.dart
│   └── mobile_config.dart
├── widgets/                         # Reusable widgets
│   ├── camera_preview_widget.dart
│   └── image_source_selector.dart
└── utils/                           # Utilities
    ├── image_utils.dart
    └── permission_helper.dart
```

## Model Configuration

The app uses configuration from `mobile_config.json`:

```json
{
  "model_info": {
    "input_shape": [1, 3, 112, 112],
    "output_shape": [1, 512],
    "input_name": "face_input",
    "output_name": "face_embedding"
  },
  "preprocessing": {
    "face_size": 112,
    "normalization": {
      "mean": [0.485, 0.456, 0.406],
      "std": [0.229, 0.224, 0.225]
    }
  },
  "matching": {
    "similarity_threshold": 0.3
  }
}
```

## Troubleshooting

### Common Issues

1. **Camera permission denied**
   - Grant camera permission in device settings
   - Restart the app

2. **Model loading fails**
   - Ensure ONNX model files are in `assets/models/`
   - Check file names match configuration

3. **Face detection not working**
   - Use well-lit images
   - Ensure face is clearly visible
   - Try different image angles

### Performance Tips

- Use images with good lighting
- Keep face images under 2MB
- Close other apps for better performance
- Test on physical device for accurate performance
