import '../location/gps_point.dart';
import '../location/ride_stats_calculator.dart';

/// Describes a single multiplier rule currently boosting XP (e.g.
/// "High Speed", worth x3). Used for the live in-ride badge.
class MultiplierInfo {
  final String id;
  final String displayName;
  final double value;

  const MultiplierInfo({
    required this.id,
    required this.displayName,
    required this.value,
  });
}

/// Full XP breakdown for a ride. [distanceXp] already has multipliers
/// baked in; [averageMultiplier] is purely a display label showing
/// how much of a boost the distance XP got on average.
class ScoreEvaluationResult {
  final int distanceXp;
  final double averageMultiplier;
  final int elevationXp;
  final int durationXp;
  final List<MultiplierInfo> currentActiveMultipliers;
  final double currentCombinedMultiplier;

  const ScoreEvaluationResult({
    required this.distanceXp,
    required this.averageMultiplier,
    required this.elevationXp,
    required this.durationXp,
    required this.currentActiveMultipliers,
    required this.currentCombinedMultiplier,
  });

  int get totalXp => distanceXp + elevationXp + durationXp;

  static const ScoreEvaluationResult empty = ScoreEvaluationResult(
    distanceXp: 0,
    averageMultiplier: 1,
    elevationXp: 0,
    durationXp: 0,
    currentActiveMultipliers: [],
    currentCombinedMultiplier: 1,
  );
}

/// Calculates ride score (XP). Call this either live during a ride
/// (only the `currentActiveMultipliers`/`currentCombinedMultiplier`
/// fields matter then, for the live badge) or once when the ride is
/// saved (the full XP breakdown is used then).
class ScoreCalculator {
  static const double _xpPerKm = 25;
  static const double _xpPer10mElevation = 8;
  static const double _xpPer10MinDuration = 3;

  static const double _highSpeedThresholdKmh = 20;
  static const double _highSpeedMultiplierValue = 3;

  static const double _consistencySpeedThresholdKmh = 15;
  static const double _consistencyDistanceMeters = 1000;
  static const double _consistencyMultiplierValue = 2;

  static const double _accuracyLimitMeters = 15;
  static const double _noiseThresholdMeters = 3;

  static ScoreEvaluationResult evaluate(
    List<GpsPoint> rawPoints, {
    double? elevationGainMetersOverride,
  }) {
    final points = rawPoints
        .where((p) => p.accuracy <= _accuracyLimitMeters)
        .toList();

    if (points.length < 2) return ScoreEvaluationResult.empty;

    double baseDistanceXp = 0;
    double weightedDistanceXp = 0;
    double consistencyStreakMeters = 0;
    GpsPoint lastAcceptedPoint = points.first;

    List<MultiplierInfo> lastActiveMultipliers = [];
    double lastCombinedMultiplier = 1;

    for (int i = 1; i < points.length; i++) {
      final current = points[i];
      final segmentDistance = RideStatsCalculator.distanceBetweenMeters(
        lastAcceptedPoint,
        current,
      );

      if (segmentDistance < _noiseThresholdMeters) continue;

      final speedKmh = current.speed * 3.6;

      if (speedKmh >= _consistencySpeedThresholdKmh) {
        consistencyStreakMeters += segmentDistance;
      } else {
        consistencyStreakMeters = 0;
      }

      final activeMultipliers = <MultiplierInfo>[];
      if (speedKmh >= _highSpeedThresholdKmh) {
        activeMultipliers.add(
          const MultiplierInfo(
            id: 'high_speed',
            displayName: 'High Speed',
            value: _highSpeedMultiplierValue,
          ),
        );
      }
      if (consistencyStreakMeters >= _consistencyDistanceMeters) {
        activeMultipliers.add(
          const MultiplierInfo(
            id: 'consistency',
            displayName: 'Consistency',
            value: _consistencyMultiplierValue,
          ),
        );
      }

      final combinedMultiplier = activeMultipliers.fold<double>(
        1,
        (acc, m) => acc * m.value,
      );

      final segmentBaseXp = (segmentDistance / 1000) * _xpPerKm;
      baseDistanceXp += segmentBaseXp;
      weightedDistanceXp += segmentBaseXp * combinedMultiplier;

      lastActiveMultipliers = activeMultipliers;
      lastCombinedMultiplier = combinedMultiplier;
      lastAcceptedPoint = current;
    }

    final elevationGain =
        elevationGainMetersOverride ??
        RideStatsCalculator.totalElevationGainMeters(points);
    final elevationXp = (elevationGain / 10) * _xpPer10mElevation;

    final movingDurationMinutes = RideStatsCalculator.movingDuration(
      points,
    ).inMinutes;
    final durationXp = (movingDurationMinutes / 10) * _xpPer10MinDuration;

    final averageMultiplier = baseDistanceXp <= 0
        ? 1.0
        : weightedDistanceXp / baseDistanceXp;

    return ScoreEvaluationResult(
      distanceXp: weightedDistanceXp.round(),
      averageMultiplier: averageMultiplier,
      elevationXp: elevationXp.round(),
      durationXp: durationXp.round(),
      currentActiveMultipliers: lastActiveMultipliers,
      currentCombinedMultiplier: lastCombinedMultiplier,
    );
  }
}
