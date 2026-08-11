import 'package:isar/isar.dart';

part 'user_profile.g.dart';

/// Stores the rider's persistent progression data. There is only
/// ever one profile record in this local database.
@collection
class UserProfile {
  Id id = Isar.autoIncrement;

  /// Permanent level — never resets, only ever goes up.
  int level = 1;

  /// XP earned toward the next level. Resets to 0 on the 1st of every
  /// calendar month (tracked via [xpPeriod]) — this also doubles as
  /// the rider's "this month" performance for a future leaderboard.
  int xp = 0;

  /// Which calendar month [xp] currently belongs to ("YYYY-MM").
  String xpPeriod = '';

  int totalGold = 0;
  int totalRidesCompleted = 0;
  double totalDistanceMeters = 0;
  double totalDurationSeconds = 0;
  double lifetimeMaxSpeedKmh = 0;
  double totalElevationGainMeters = 0;
}
