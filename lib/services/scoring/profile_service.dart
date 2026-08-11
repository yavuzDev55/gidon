import 'package:isar/isar.dart';
import 'level_calculator.dart';
import 'user_profile.dart';

/// Result of applying a ride's rewards to the profile.
class RideRewardResult {
  final UserProfile profile;
  final int levelsGained;
  final int goldEarned;

  const RideRewardResult({
    required this.profile,
    required this.levelsGained,
    required this.goldEarned,
  });

  bool get leveledUp => levelsGained > 0;
}

/// Manages reading and updating the rider's persistent profile.
class ProfileService {
  final Isar isar;

  ProfileService(this.isar);

  static const int _profileId = 1;
  static const int _goldPerLevel = 50;

  String currentMonthPeriod() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  Future<UserProfile> getProfile() async {
    final existing = await isar.userProfiles.get(_profileId);
    if (existing != null) return existing;

    final fresh = UserProfile()
      ..id = _profileId
      ..xpPeriod = currentMonthPeriod();

    await isar.writeTxn(() async {
      await isar.userProfiles.put(fresh);
    });
    return fresh;
  }

  /// Adds [xpToAdd] to a level/xp pair, rolling over into as many
  /// level-ups as the XP allows. Pure function — used both for the
  /// real save and for previewing the result before saving.
  static ({int level, int xp, int levelsGained}) computeProgression({
    required int currentLevel,
    required int currentXp,
    required int xpToAdd,
  }) {
    int level = currentLevel;
    int xp = currentXp + xpToAdd;
    int levelsGained = 0;

    while (xp >= LevelCalculator.xpRequiredForLevel(level)) {
      xp -= LevelCalculator.xpRequiredForLevel(level);
      level++;
      levelsGained++;
    }

    return (level: level, xp: xp, levelsGained: levelsGained);
  }

  /// Applies the rewards from a completed ride.
  Future<RideRewardResult> applyRideRewards({
    required int xpEarned,
    required double distanceMeters,
    required double durationSeconds,
    required double maxSpeedKmh,
    required double elevationGainMeters,
  }) async {
    final profile = await getProfile();
    final currentPeriod = currentMonthPeriod();

    if (profile.xpPeriod != currentPeriod) {
      profile.xpPeriod = currentPeriod;
      profile.xp = 0;
    }

    final progression = computeProgression(
      currentLevel: profile.level,
      currentXp: profile.xp,
      xpToAdd: xpEarned,
    );

    profile.level = progression.level;
    profile.xp = progression.xp;

    final goldEarned = progression.levelsGained * _goldPerLevel;
    profile.totalGold += goldEarned;
    profile.totalRidesCompleted += 1;
    profile.totalDistanceMeters += distanceMeters;
    profile.totalDurationSeconds += durationSeconds;
    if (maxSpeedKmh > profile.lifetimeMaxSpeedKmh) {
      profile.lifetimeMaxSpeedKmh = maxSpeedKmh;
    }

    profile.totalElevationGainMeters += elevationGainMeters;

    await isar.writeTxn(() async {
      await isar.userProfiles.put(profile);
    });

    return RideRewardResult(
      profile: profile,
      levelsGained: progression.levelsGained,
      goldEarned: goldEarned,
    );
  }
}
