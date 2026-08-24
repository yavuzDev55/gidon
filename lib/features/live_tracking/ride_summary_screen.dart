import 'package:flutter/material.dart';
import '../../services/location/gps_point.dart';
import '../../services/location/isar_service.dart';
import '../../services/location/ride_meta.dart';
import '../../services/location/ride_stats_calculator.dart';
import '../../services/scoring/profile_service.dart';
import '../../services/scoring/score_calculator.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'route_map_view.dart';

/// The final step of the ride flow: name/describe the ride, review
/// its stats, and confirm (Save) or Discard it. This is where the
/// ride and its rewards are actually committed to the database.
///
/// When [isPendingConfirmation] is false, this is a historical,
/// already-saved ride viewed read-only (from Profile/Ride History).
/// In that mode the screen can be popped with `true` to signal that
/// the ride was deleted, so the caller can refresh its list.
class RideSummaryScreen extends StatefulWidget {
  final RideSummary summary;
  final List<GpsPoint> points;
  final ScoreEvaluationResult? scoreResult;
  final IsarService isarService;
  final String rideId;
  final bool isPendingConfirmation;

  const RideSummaryScreen({
    super.key,
    required this.summary,
    required this.points,
    required this.isarService,
    required this.rideId,
    this.scoreResult,
    this.isPendingConfirmation = false,
  });

  @override
  State<RideSummaryScreen> createState() => _RideSummaryScreenState();
}

class _RideSummaryScreenState extends State<RideSummaryScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  bool _isProcessing = false;
  RideMeta? _existingMeta;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    if (!widget.isPendingConfirmation) {
      _loadExistingMeta();
    }
  }

  Future<void> _loadExistingMeta() async {
    final meta = await widget.isarService.getRideMeta(widget.rideId);
    if (mounted) setState(() => _existingMeta = meta);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _handleDiscard() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard ride?'),
        content: const Text(
          'This ride and its rewards will not be saved. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep reviewing'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isProcessing = true);
    await widget.isarService.deletePointsForRide(widget.rideId);
    await widget.isarService.deleteRideMeta(widget.rideId);

    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  Future<void> _handleSave() async {
    setState(() => _isProcessing = true);

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    await widget.isarService.saveRideMeta(
      widget.rideId,
      name: name.isEmpty ? _defaultName() : name,
      description: description,
    );

    if (widget.scoreResult != null) {
      final profileService = ProfileService(widget.isarService.isar);
      await profileService.applyRideRewards(
        xpEarned: widget.scoreResult!.totalXp,
        distanceMeters: widget.summary.totalDistanceMeters,
        durationSeconds: widget.summary.duration.inSeconds.toDouble(),
        maxSpeedKmh: widget.summary.maxSpeedKmh,
        elevationGainMeters: widget.summary.elevationGainMeters,
      );
    }

    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  /// Deletes an already-saved ride from history. Only removes this
  /// ride's raw GPS points ([GpsPoint]) and its name/description
  /// record ([RideMeta]) — the rider's aggregate progression
  /// ([UserProfile]: xp, level, totalDistanceMeters, totalGold, etc.)
  /// lives in a completely separate Isar collection that is written
  /// once, at save time, and never references individual rides. So
  /// deleting a ride from history cannot change those totals.
  Future<void> _handleDeleteSavedRide() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.yellow,
        title: Text(
          'Delete ride?',
          style: AppTypography.heading(color: AppColors.black, fontSize: 20),
        ),
        content: Text(
          'Your stats won\'t be affected.',
          style: AppTypography.body(color: AppColors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: AppTypography.label(color: AppColors.black),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Delete',
              style: AppTypography.label(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isProcessing = true);

    await widget.isarService.deletePointsForRide(widget.rideId);
    await widget.isarService.deleteRideMeta(widget.rideId);

    if (mounted) {
      // Returning `true` tells the caller (Profile / Ride History /
      // All Rides) that a ride was deleted, so it can refresh its list.
      Navigator.of(context).pop(true);
    }
  }

  String _defaultName() {
    final now = DateTime.now();
    return 'Ride ${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: ListView(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 220,
                  child: RouteMapView(points: widget.points),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: widget.isPendingConfirmation
                      ? IconButton(
                          onPressed: _isProcessing ? null : _handleDiscard,
                          icon: const Icon(Icons.close),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.black,
                            foregroundColor: AppColors.white,
                          ),
                        )
                      : IconButton(
                          onPressed: _isProcessing
                              ? null
                              : () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.black,
                            foregroundColor: AppColors.white,
                          ),
                        ),
                ),
                if (widget.isPendingConfirmation)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      onPressed: _isProcessing ? null : _handleSave,
                      icon: const Icon(Icons.save),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.yellow,
                        foregroundColor: AppColors.black,
                      ),
                    ),
                  )
                else
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      onPressed: _isProcessing ? null : _handleDeleteSavedRide,
                      icon: const Icon(Icons.delete_outline),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        foregroundColor: AppColors.white,
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.isPendingConfirmation) ...[
                    TextField(
                      controller: _nameController,
                      style: AppTypography.heading(
                        color: AppColors.black,
                        fontSize: 20,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Route Name',
                        hintStyle: AppTypography.heading(
                          color: AppColors.black.withValues(alpha: 0.4),
                          fontSize: 20,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                    TextField(
                      controller: _descriptionController,
                      style: AppTypography.body(
                        color: AppColors.black.withValues(alpha: 0.7),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Description...',
                        hintStyle: AppTypography.body(
                          color: AppColors.black.withValues(alpha: 0.35),
                        ),
                        border: InputBorder.none,
                      ),
                      maxLines: 2,
                    ),
                  ] else ...[
                    Text(
                      _existingMeta?.name.isNotEmpty == true
                          ? _existingMeta!.name
                          : 'Route Name',
                      style: AppTypography.heading(
                        color: AppColors.black,
                        fontSize: 20,
                      ),
                    ),
                    if (_existingMeta?.description.isNotEmpty == true)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _existingMeta!.description,
                          style: AppTypography.body(
                            color: AppColors.black.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                  ],
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _StatLine(
                          label: 'Distance:',
                          value:
                              '${(widget.summary.totalDistanceMeters / 1000).toStringAsFixed(1)}',
                          unit: 'km',
                        ),
                        _StatLine(
                          label: 'Time:',
                          value: _formatDuration(widget.summary.duration),
                          unit: '',
                        ),
                        _StatLine(
                          label: 'Average Speed:',
                          value: widget.summary.averageSpeedKmh.toStringAsFixed(
                            1,
                          ),
                          unit: 'kmph',
                        ),
                        _StatLine(
                          label: 'Max Speed:',
                          value: widget.summary.maxSpeedKmh.toStringAsFixed(1),
                          unit: 'kmph',
                        ),
                        _StatLine(
                          label: 'Elevation:',
                          value: widget.summary.elevationGainMeters
                              .toStringAsFixed(0),
                          unit: 'meter',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatLine extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _StatLine({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: AppTypography.body(color: AppColors.white, fontSize: 14),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: AppTypography.heading(color: AppColors.yellow, fontSize: 20),
          ),
          if (unit.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              unit,
              style: AppTypography.label(
                color: AppColors.yellow.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
