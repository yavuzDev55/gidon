import 'dart:async';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';

import '../location/gps_point.dart';
import '../location/isar_service.dart';

const String _notificationChannelId = 'gidon_ride_tracking';
const int _notificationId = 888;

/// Sets up and registers the background service with Android.
/// Must be called once during app startup, before the service is used.
Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  const notificationChannel = AndroidNotificationChannel(
    _notificationChannelId,
    'Ride Tracking',
    description:
        'Shows an active notification while your ride is being recorded.',
    importance: Importance.low,
  );

  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  final androidPlugin = notificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  await androidPlugin?.createNotificationChannel(notificationChannel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onServiceStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: _notificationChannelId,
      initialNotificationTitle: 'Gidon',
      initialNotificationContent: 'Preparing ride tracking...',
      foregroundServiceNotificationId: _notificationId,
      foregroundServiceTypes: [AndroidForegroundType.location],
    ),
    iosConfiguration: IosConfiguration(),
  );
}

/// Entry point for the background isolate. This runs completely
/// separately from the main app UI, so it must open its own
/// database connection and GPS stream.
@pragma('vm:entry-point')
void onServiceStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  final isarService = IsarService();
  await isarService.initialize();

  // Signals to the UI that this service instance is fully initialized
  // and ready to receive commands (fixes a race condition where
  // 'startRide' could be sent before this isolate finished booting).
  service.invoke('ready');

  String? currentRideId;
  StreamSubscription<Position>? positionSubscription;

  service.on('startRide').listen((event) {
    currentRideId = event?['rideId'] as String?;

    positionSubscription =
        Geolocator.getPositionStream(
          locationSettings: AndroidSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 0,
            intervalDuration: Duration(seconds: 2),
            forceLocationManager: false,
          ),
        ).listen((position) async {
          if (currentRideId == null) return;

          final point = GpsPoint()
            ..rideId = currentRideId!
            ..latitude = position.latitude
            ..longitude = position.longitude
            ..altitude = position.altitude
            ..speed = position.speed
            ..accuracy = position.accuracy
            ..timestamp = position.timestamp.toUtc();

          await isarService.saveGpsPoint(point);

          if (service is AndroidServiceInstance) {
            service.setForegroundNotificationInfo(
              title: 'Gidon - Recording your ride',
              content:
                  'Speed: ${(position.speed * 3.6).toStringAsFixed(1)} km/h',
            );
          }
        });
  });

  service.on('stopRide').listen((event) {
    positionSubscription?.cancel();
    positionSubscription = null;
    currentRideId = null;
    service.stopSelf();
  });
}
