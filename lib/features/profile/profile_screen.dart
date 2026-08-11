import 'package:flutter/material.dart';
import '../../services/location/isar_service.dart';
import '../../services/location/ride_stats_calculator.dart';
import '../../services/scoring/profile_service.dart';
import '../../services/scoring/score_calculator.dart';
import '../../services/scoring/user_profile.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../live_tracking/ride_summary_screen.dart';
import '../ride_history/all_rides_screen.dart';

/// The rider's profile: level, lifetime stats, and recent rides.
/// Matches the dark-themed mockup — red avatar placeholder, yellow
/// name/level pill, a stats card, and a recently-rides list.
class ProfileScreen extends StatefulWidget {
  final IsarService isarService;

  const ProfileScreen({super.key, required this.isarService});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<(UserProfile, List<RideOverview>)> _dataFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _dataFuture = _fetchData();
  }

  Future<(UserProfile, List<RideOverview>)> _fetchData() async {
    final profile = await ProfileService(widget.isarService.isar).getProfile();
    final rides = await widget.isarService.getAllRideOverviews();
    return (profile, rides);
  }

  Future<void> _refresh() async {
    setState(_load);
  }

  Future<void> _openRideSummary(String rideId) async {
    final points = await widget.isarService.getPointsForRide(rideId);
    final summary = RideSummary.fromPoints(points);

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RideSummaryScreen(
            summary: summary,
            points: points,
            isarService: widget.isarService,
            rideId: rideId,
            isPendingConfirmation: false,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<(UserProfile, List<RideOverview>)>(
            future: _dataFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.yellow),
                );
              }

              final (profile, rides) = snapshot.data!;

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Settings coming soon'),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.settings,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: AppColors.white,
                        size: 48,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.yellow,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Guest',
                          style: AppTypography.heading(
                            color: AppColors.black,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          'Level ${profile.level}',
                          style: AppTypography.body(
                            color: AppColors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _StatLine(
                          label: 'Total distance:',
                          value: (profile.totalDistanceMeters / 1000)
                              .toStringAsFixed(0),
                          unit: 'km',
                        ),
                        _StatLine(
                          label: 'Total duration:',
                          value: (profile.totalDurationSeconds / 3600)
                              .toStringAsFixed(2),
                          unit: 'h',
                        ),
                        _StatLine(
                          label: 'Average Speed:',
                          value: _averageSpeedKmh(profile).toStringAsFixed(1),
                          unit: 'kmph',
                        ),
                        _StatLine(
                          label: 'Max Speed:',
                          value: profile.lifetimeMaxSpeedKmh.toStringAsFixed(1),
                          unit: 'kmph',
                        ),
                        _StatLine(
                          label: 'Elevation Gain:',
                          value: profile.totalElevationGainMeters
                              .toStringAsFixed(0),
                          unit: 'meter',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AllRidesScreen(
                                isarService: widget.isarService,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Recently Rides:',
                                style: AppTypography.body(
                                  color: AppColors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: AppColors.black.withValues(alpha: 0.5),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (rides.isEmpty)
                          Text(
                            'No rides recorded yet.',
                            style: AppTypography.body(
                              color: AppColors.black.withValues(alpha: 0.5),
                              fontSize: 14,
                            ),
                          )
                        else
                          ...rides
                              .take(3)
                              .map(
                                (ride) => _RecentRideRow(
                                  ride: ride,
                                  onTap: () => _openRideSummary(ride.rideId),
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  double _averageSpeedKmh(UserProfile profile) {
    if (profile.totalDurationSeconds <= 0) return 0;
    final avgSpeedMs =
        profile.totalDistanceMeters / profile.totalDurationSeconds;
    return avgSpeedMs * 3.6;
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
            style: AppTypography.body(color: AppColors.black, fontSize: 15),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: AppTypography.heading(color: AppColors.black, fontSize: 22),
          ),
          const SizedBox(width: 4),
          Text(
            unit,
            style: AppTypography.label(
              color: AppColors.black.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentRideRow extends StatelessWidget {
  final RideOverview ride;
  final VoidCallback onTap;

  const _RecentRideRow({required this.ride, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final local = ride.startTime.toLocal();
    final dateLabel =
        '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/${local.year}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.directions_bike, color: AppColors.black, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                ride.name?.isNotEmpty == true ? ride.name! : dateLabel,
                style: AppTypography.body(color: AppColors.black, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.black.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}
