import 'dart:async';
import 'package:geolocator/geolocator.dart';

/// Streams live GPS position updates (location, speed, heading, accuracy).
class LocationStreamService {
  StreamSubscription<Position>? _subscription;
  final StreamController<Position> _controller =
      StreamController<Position>.broadcast();

  Stream<Position> get positionStream => _controller.stream;

  /// Android-specific settings: requests an update at least every
  /// 2 seconds (matching what competing apps like Cyclers/Strava do),
  /// with no minimum distance filter so we get every update on time.
  static final AndroidSettings _locationSettings = AndroidSettings(
    accuracy: LocationAccuracy.best,
    distanceFilter: 0,
    intervalDuration: Duration(seconds: 2),
    forceLocationManager: false,
  );

  void start() {
    _subscription =
        Geolocator.getPositionStream(
          locationSettings: _locationSettings,
        ).listen(
          (Position position) => _controller.add(position),
          onError: (error) => _controller.addError(error),
        );
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
  }

  void dispose() {
    stop();
    _controller.close();
  }
}
