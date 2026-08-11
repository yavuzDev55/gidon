import 'package:flutter/material.dart';
import '../../services/location/gps_point.dart';
import '../../services/location/isar_service.dart';
import '../../services/location/ride_stats_calculator.dart';
import '../../services/scoring/level_calculator.dart';
import '../../services/scoring/profile_service.dart';
import '../../services/scoring/score_calculator.dart';
import '../../services/scoring/user_profile.dart';
import '../../theme/app_colors.dart';
import '../live_tracking/ride_summary_screen.dart';

/// Shown right after a ride ends, before anything is saved. Reveals
/// XP sources one by one (Distance → Elevation → Duration), then the
/// total, then a PREVIEW of the Level/XP bar — nothing is written to
/// the database yet. Tapping "Next" moves on to the naming/save
/// screen, where the ride (and these rewards) are actually committed.
class ProgressionResultScreen extends StatefulWidget {
  final ScoreEvaluationResult scoreResult;
  final RideSummary summary;
  final List<GpsPoint> points;
  final IsarService isarService;
  final String rideId;

  const ProgressionResultScreen({
    super.key,
    required this.scoreResult,
    required this.summary,
    required this.points,
    required this.isarService,
    required this.rideId,
  });

  @override
  State<ProgressionResultScreen> createState() =>
      _ProgressionResultScreenState();
}

class _ProgressionResultScreenState extends State<ProgressionResultScreen> {
  int _phase = 0;
  bool _skipped = false;
  late Future<UserProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = ProfileService(widget.isarService.isar).getProfile();
    _playSequence();
  }

  Future<void> _playSequence() async {
    if (!await _wait(500)) return;
    setState(() => _phase = 1);
    if (!await _wait(800)) return;
    setState(() => _phase = 2);
    if (!await _wait(800)) return;
    setState(() => _phase = 3);
    if (!await _wait(800)) return;
    setState(() => _phase = 4);
  }

  Future<bool> _wait(int ms) async {
    final stopwatch = Stopwatch()..start();
    while (stopwatch.elapsedMilliseconds < ms) {
      if (_skipped) return false;
      await Future.delayed(const Duration(milliseconds: 30));
    }
    return !_skipped;
  }

  void _skipToEnd() {
    if (_skipped) return;
    setState(() {
      _skipped = true;
      _phase = 4;
    });
  }

  void _goToNamingScreen(UserProfile currentProfile) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RideSummaryScreen(
          summary: widget.summary,
          points: widget.points,
          scoreResult: widget.scoreResult,
          isarService: widget.isarService,
          rideId: widget.rideId,
          isPendingConfirmation: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.scoreResult;
    final animationDuration = _skipped
        ? Duration.zero
        : const Duration(milliseconds: 700);

    return FutureBuilder<UserProfile>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: AppColors.yellow,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.black),
            ),
          );
        }

        final profile = snapshot.data!;
        final preview = ProfileService.computeProgression(
          currentLevel: profile.level,
          currentXp: profile.xp,
          xpToAdd: result.totalXp,
        );
        final leveledUp = preview.levelsGained > 0;

        return GestureDetector(
          onTap: _skipToEnd,
          behavior: HitTestBehavior.opaque,
          child: Scaffold(
            backgroundColor: AppColors.yellow,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_phase >= 1)
                      _XpLine(
                        label: 'Distance gain',
                        value: result.distanceXp,
                        suffix: result.averageMultiplier > 1.05
                            ? ' (x${result.averageMultiplier.toStringAsFixed(1)})'
                            : null,
                        duration: animationDuration,
                      ),
                    if (_phase >= 2)
                      _XpLine(
                        label: 'Elevation gain',
                        value: result.elevationXp,
                        duration: animationDuration,
                      ),
                    if (_phase >= 3)
                      _XpLine(
                        label: 'Duration gain',
                        value: result.durationXp,
                        duration: animationDuration,
                      ),
                    if (_phase >= 4) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Total xp: ${result.totalXp}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 32),
                      if (leveledUp) ...[
                        const Icon(
                          Icons.emoji_events,
                          color: AppColors.black,
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Level Up!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Text(
                        'Level ${preview.level}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _LevelBar(
                        beforeLevel: profile.level,
                        beforeXp: leveledUp ? 0 : profile.xp,
                        afterLevel: preview.level,
                        afterXp: preview.xp,
                        duration: animationDuration == Duration.zero
                            ? Duration.zero
                            : const Duration(milliseconds: 1200),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        onPressed: () => _goToNamingScreen(profile),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.black,
                          foregroundColor: AppColors.white,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(18),
                        ),
                        icon: const Icon(Icons.arrow_forward),
                        label: const SizedBox.shrink(),
                      ),
                    ] else
                      const Text(
                        'Tap to skip',
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _XpLine extends StatelessWidget {
  final String label;
  final int value;
  final String? suffix;
  final Duration duration;

  const _XpLine({
    required this.label,
    required this.value,
    required this.duration,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TweenAnimationBuilder<int>(
        tween: IntTween(begin: 0, end: value),
        duration: duration,
        curve: Curves.easeOutCubic,
        builder: (context, animatedValue, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$label: ',
              style: const TextStyle(fontSize: 15, color: AppColors.black),
            ),
            Text(
              '$animatedValue xp${suffix ?? ''}',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelBar extends StatelessWidget {
  final int beforeLevel;
  final int beforeXp;
  final int afterLevel;
  final int afterXp;
  final Duration duration;

  const _LevelBar({
    required this.beforeLevel,
    required this.beforeXp,
    required this.afterLevel,
    required this.afterXp,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final leveledUp = afterLevel > beforeLevel;
    final xpNeededAfter = LevelCalculator.xpRequiredForLevel(afterLevel);
    final xpNeededBefore = LevelCalculator.xpRequiredForLevel(beforeLevel);

    final startFraction = leveledUp
        ? 0.0
        : (xpNeededBefore == 0 ? 0.0 : beforeXp / xpNeededBefore);
    final endFraction = xpNeededAfter == 0 ? 0.0 : afterXp / xpNeededAfter;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: startFraction, end: endFraction),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LinearProgressIndicator(
          value: value,
          minHeight: 8,
          backgroundColor: Colors.black26,
          valueColor: const AlwaysStoppedAnimation(AppColors.black),
        ),
      ),
    );
  }
}
