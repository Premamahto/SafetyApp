import 'package:permission_handler/permission_handler.dart';

/// Requests all required permissions on first launch.
/// After the user grants them once, Android remembers — no repeated prompts.
class PermissionService {
  static Future<void> requestAll() async {
    await [
      Permission.sms,
      Permission.phone,
      Permission.location,
      Permission.locationWhenInUse,
    ].request();
  }

  static Future<bool> isSmsGranted() async =>
      await Permission.sms.isGranted;
}
