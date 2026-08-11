import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'gps_point.dart';
import 'isar_service.dart';
import 'location_stream_service.dart';

/// Coordinates a single ride: listens to the GPS stream and
/// persists every reading into the database as a GpsPoint,
/// tagged with the current ride's unique ID.
class RideSessionService {
  final LocationStreamService _locationStreamService;
  final IsarService _isarService;

  StreamSubscription<Position>? _subscription;
  String? _currentRideId;

  RideSessionService(this._locationStreamService, this._isarService);

  bool get isRideActive => _currentRideId != null;
  String? get currentRideId => _currentRideId;

  /// Starts a new ride session. Generates a unique ride ID based
  /// on the current timestamp and begins recording GPS points.
  void startRide() {
    if (isRideActive) return;

    _currentRideId = DateTime.now().toUtc().toIso8601String();
    _locationStreamService.start();

    _subscription = _locationStreamService.positionStream.listen(
      (position) => _handleNewPosition(position),
    );
  }

  Future<void> _handleNewPosition(Position position) async {
    if (_currentRideId == null) return;

    final point = GpsPoint()
      ..rideId = _currentRideId!
      ..latitude = position.latitude
      ..longitude = position.longitude
      ..altitude = position.altitude
      ..speed = position.speed
      ..accuracy = position.accuracy
      ..timestamp = position.timestamp.toUtc();

    await _isarService.saveGpsPoint(point);
  }

  /// Stops the current ride session and the GPS stream.
  void stopRide() {
    _subscription?.cancel();
    _subscription = null;
    _locationStreamService.stop();
    _currentRideId = null;
  }
}
