import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();

    switch (status) {
      case PermissionStatus.granted:
        print('✅ Camera permission granted');
        return true;
      case PermissionStatus.denied:
        print('❌ Camera permission denied');
        return false;
      case PermissionStatus.permanentlyDenied:
        print('❌ Camera permission permanently denied');
        await openAppSettings();
        return false;
      case PermissionStatus.restricted:
        print('❌ Camera permission restricted');
        return false;
      default:
        return false;
    }
  }

  static Future<bool> hasCameraPermission() async {
    final status = await Permission.camera.status;
    return status == PermissionStatus.granted;
  }
}
