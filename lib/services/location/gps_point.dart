import 'package:isar/isar.dart';

part 'gps_point.g.dart';

/// Represents a single GPS reading captured during a ride.
/// This is the core data unit for the Black Box, Ghost Map,
/// and Blind Explorer features.
@collection
class GpsPoint {
  Id id = Isar.autoIncrement;

  /// Identifies which ride session this point belongs to.
  /// Indexed so we can quickly fetch all points of a specific ride.
  @Index()
  late String rideId;

  late double latitude;
  late double longitude;

  /// Altitude in meters, used for climb/elevation calculations.
  late double altitude;

  /// Speed in meters per second (raw value from GPS).
  late double speed;

  /// GPS accuracy in meters. Lower is better.
  late double accuracy;

  /// UTC timestamp of when this point was recorded.
  /// Indexed to support fast time-based queries (e.g. Ghost Map).
  @Index()
  late DateTime timestamp;
}
