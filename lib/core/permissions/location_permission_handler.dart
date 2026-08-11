import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Handles location permission requests and service checks.
class LocationPermissionHandler {
  /// Ensures location services are enabled and permissions are granted.
  /// Throws an exception if the user denies access.
  static Future<bool> ensurePermissions() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServiceDisabledException();
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const PermissionDeniedException(
          'Location permission was denied. The app cannot function.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const PermissionDeniedException(
        'Location permission is permanently denied. '
        'Please enable it from the device settings.',
      );
    }

    // whileInUse is enough for now; background permission will be
    // requested separately in Step 2.
    return true;
  }

  /// Requests notification permission, required on Android 13+ (API 33+)
  /// for the foreground service notification to actually be visible.
  static Future<void> ensureNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      await Permission.notification.request();
    }
  }
}
