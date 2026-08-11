import 'dart:math';
import 'gps_point.dart';

/// Calculates ride statistics (distance, speed, duration, acceleration)
/// from recorded GPS points.
class RideStatsCalculator {
  static const double _earthRadiusMeters = 6371000;

  /// Minimum distance (in meters) between two points to be counted as
  /// real movement. Anything smaller is treated as GPS noise/jitter.
  static const double _noiseThresholdMeters = 3.0;

  /// Points with a reported accuracy worse than this (in meters) are
  /// excluded from all statistics.
  static const double _maxAcceptableAccuracyMeters = 15.0;

  /// Auto-pause: if speed stays below this threshold for
  /// [_autoPauseDelaySeconds] or more, that stretch is excluded from
  /// distance/duration/speed statistics (raw GPS points are still
  /// kept in the database — this only affects computed stats).
  static const double _autoPauseSpeedThresholdKmh = 5.0;
  static const int _autoPauseDelaySeconds = 30;

  static List<GpsPoint> _filterAccuratePoints(List<GpsPoint> points) {
    return points
        .where((p) => p.accuracy <= _maxAcceptableAccuracyMeters)
        .toList();
  }

  static double distanceBetweenMeters(GpsPoint a, GpsPoint b) {
    final lat1 = _degreesToRadians(a.latitude);
    final lat2 = _degreesToRadians(b.latitude);
    final deltaLat = _degreesToRadians(b.latitude - a.latitude);
    final deltaLon = _degreesToRadians(b.longitude - a.longitude);

    final h =
        sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1) * cos(lat2) * sin(deltaLon / 2) * sin(deltaLon / 2);
    final c = 2 * atan2(sqrt(h), sqrt(1 - h));

    return _earthRadiusMeters * c;
  }

  /// Splits points into "moving" segments, excluding stretches where
  /// speed stayed below the auto-pause threshold for 30+ continuous
  /// seconds. Used by distance/speed calculations.
  static List<GpsPoint> filterMovingSegments(List<GpsPoint> points) {
    if (points.length < 2) return points;

    final result = <GpsPoint>[points.first];
    DateTime? slowStreakStart;

    for (int i = 1; i < points.length; i++) {
      final speedKmh = points[i].speed * 3.6;
      final isSlow = speedKmh < _autoPauseSpeedThresholdKmh;

      if (isSlow) {
        slowStreakStart ??= points[i - 1].timestamp;
        final slowDuration = points[i].timestamp
            .difference(slowStreakStart)
            .inSeconds;
        if (slowDuration >= _autoPauseDelaySeconds) {
          continue;
        }
      } else {
        slowStreakStart = null;
      }

      result.add(points[i]);
    }

    return result;
  }

  /// Total elapsed time actually spent moving — sums only the
  /// time intervals NOT classified as an auto-pause. This is what
  /// "ride duration" means throughout the app (matches Strava's
  /// "moving time" concept).
  static Duration movingDuration(List<GpsPoint> rawPoints) {
    final points = _filterAccuratePoints(rawPoints);
    if (points.length < 2) return Duration.zero;

    Duration total = Duration.zero;
    DateTime? slowStreakStart;

    for (int i = 1; i < points.length; i++) {
      final delta = points[i].timestamp.difference(points[i - 1].timestamp);
      final speedKmh = points[i].speed * 3.6;
      final isSlow = speedKmh < _autoPauseSpeedThresholdKmh;

      if (isSlow) {
        slowStreakStart ??= points[i - 1].timestamp;
        final slowDurationSoFar = points[i].timestamp
            .difference(slowStreakStart)
            .inSeconds;
        if (slowDurationSoFar >= _autoPauseDelaySeconds) {
          continue;
        }
      } else {
        slowStreakStart = null;
      }

      total += delta;
    }

    return total;
  }

  static double totalDistanceMeters(List<GpsPoint> rawPoints) {
    final accuratePoints = _filterAccuratePoints(rawPoints);
    final points = filterMovingSegments(accuratePoints);
    if (points.isEmpty) return 0;

    double total = 0;
    GpsPoint lastAcceptedPoint = points.first;

    for (int i = 1; i < points.length; i++) {
      final segmentDistance = distanceBetweenMeters(
        lastAcceptedPoint,
        points[i],
      );
      if (segmentDistance >= _noiseThresholdMeters) {
        total += segmentDistance;
        lastAcceptedPoint = points[i];
      }
    }

    return total;
  }

  /// Total positive altitude change across the ride — how much the
  /// rider climbed in total (descents don't subtract from this).
  static double totalElevationGainMeters(List<GpsPoint> rawPoints) {
    final points = _filterAccuratePoints(rawPoints);
    if (points.length < 2) return 0;

    double gain = 0;
    for (int i = 1; i < points.length; i++) {
      final delta = points[i].altitude - points[i - 1].altitude;
      if (delta > 0) gain += delta;
    }
    return gain;
  }

  static double maxSpeedMetersPerSecond(List<GpsPoint> rawPoints) {
    final accuratePoints = _filterAccuratePoints(rawPoints);
    final points = filterMovingSegments(accuratePoints);
    if (points.isEmpty) return 0;
    return points.map((p) => p.speed).reduce(max);
  }

  static double averageSpeedMetersPerSecond(List<GpsPoint> rawPoints) {
    final distance = totalDistanceMeters(rawPoints);
    final durationSeconds = movingDuration(rawPoints).inSeconds;
    if (durationSeconds <= 0) return 0;
    return distance / durationSeconds;
  }

  static double currentAccelerationMetersPerSecondSquared(
    List<GpsPoint> rawPoints,
  ) {
    final accuratePoints = _filterAccuratePoints(rawPoints);
    final points = filterMovingSegments(accuratePoints);
    if (points.length < 2) return 0;

    final previous = points[points.length - 2];
    final latest = points[points.length - 1];

    final speedDelta = latest.speed - previous.speed;
    final timeDeltaSeconds =
        latest.timestamp.difference(previous.timestamp).inMilliseconds / 1000;

    if (timeDeltaSeconds <= 0) return 0;
    return speedDelta / timeDeltaSeconds;
  }

  /// Returns a cleaned subset of points suitable for drawing a route
  /// line on a map: drops inaccurate readings and collapses GPS
  /// jitter, so the line doesn't zig-zag or jump when the rider is
  /// stationary or the phone shakes.
  static List<GpsPoint> filterForDisplay(List<GpsPoint> rawPoints) {
    final accuratePoints = _filterAccuratePoints(rawPoints);
    if (accuratePoints.isEmpty) return [];

    final result = <GpsPoint>[accuratePoints.first];
    GpsPoint lastAccepted = accuratePoints.first;

    for (int i = 1; i < accuratePoints.length; i++) {
      final distance = distanceBetweenMeters(lastAccepted, accuratePoints[i]);
      if (distance >= _noiseThresholdMeters) {
        result.add(accuratePoints[i]);
        lastAccepted = accuratePoints[i];
      }
    }
    return result;
  }

  static double _degreesToRadians(double degrees) => degrees * pi / 180;
}

/// Holds the calculated summary statistics for a completed ride.
class RideSummary {
  final int pointCount;
  final double totalDistanceMeters;
  final double averageSpeedKmh;
  final double maxSpeedKmh;
  final double elevationGainMeters;
  final Duration duration;

  const RideSummary({
    required this.pointCount,
    required this.totalDistanceMeters,
    required this.averageSpeedKmh,
    required this.maxSpeedKmh,
    required this.elevationGainMeters,
    required this.duration,
  });

  factory RideSummary.fromPoints(List<GpsPoint> points) {
    if (points.isEmpty) {
      return const RideSummary(
        pointCount: 0,
        totalDistanceMeters: 0,
        averageSpeedKmh: 0,
        maxSpeedKmh: 0,
        elevationGainMeters: 0,
        duration: Duration.zero,
      );
    }

    return RideSummary(
      pointCount: points.length,
      totalDistanceMeters: RideStatsCalculator.totalDistanceMeters(points),
      averageSpeedKmh:
          RideStatsCalculator.averageSpeedMetersPerSecond(points) * 3.6,
      maxSpeedKmh: RideStatsCalculator.maxSpeedMetersPerSecond(points) * 3.6,
      elevationGainMeters: RideStatsCalculator.totalElevationGainMeters(points),
      duration: RideStatsCalculator.movingDuration(points),
    );
  }
}
