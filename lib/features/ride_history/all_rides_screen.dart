import 'package:flutter/material.dart';
import '../../services/location/isar_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../live_tracking/ride_summary_screen.dart';
import '../../services/location/ride_stats_calculator.dart';

/// Full list of recorded rides, with sort options (most recent,
/// distance, average speed, duration).
class AllRidesScreen extends StatefulWidget {
  final IsarService isarService;

  const AllRidesScreen({super.key, required this.isarService});

  @override
  State<AllRidesScreen> createState() => _AllRidesScreenState();
}

class _AllRidesScreenState extends State<AllRidesScreen> {
  RideSortOption _sortOption = RideSortOption.mostRecent;
  late Future<List<RideOverview>> _ridesFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _ridesFuture = widget.isarService.getAllRideOverviews(sortBy: _sortOption);
  }

  void _changeSort(RideSortOption option) {
    setState(() {
      _sortOption = option;
      _load();
    });
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

  String _formatDate(DateTime utcTime) {
    final local = utcTime.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/${local.year}';
  }

  String _sortLabel(RideSortOption option) {
    switch (option) {
      case RideSortOption.mostRecent:
        return 'Most Recent';
      case RideSortOption.distance:
        return 'Distance';
      case RideSortOption.averageSpeed:
        return 'Avg Speed';
      case RideSortOption.duration:
        return 'Duration';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.white,
        title: const Text('All Rides'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: RideSortOption.values.map((option) {
                  final isSelected = option == _sortOption;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_sortLabel(option)),
                      selected: isSelected,
                      onSelected: (_) => _changeSort(option),
                      selectedColor: AppColors.yellow,
                      backgroundColor: AppColors.secondaryBlack,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.black : AppColors.white,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<RideOverview>>(
              future: _ridesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.yellow),
                  );
                }

                final rides = snapshot.data ?? [];
                if (rides.isEmpty) {
                  return Center(
                    child: Text(
                      'No rides yet.',
                      style: AppTypography.body(color: AppColors.white),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: rides.length,
                  itemBuilder: (context, index) {
                    final ride = rides[index];
                    return Card(
                      color: AppColors.secondaryBlack,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: const Icon(
                          Icons.directions_bike,
                          color: AppColors.yellow,
                        ),
                        title: Text(
                          ride.name?.isNotEmpty == true
                              ? ride.name!
                              : _formatDate(ride.startTime),
                          style: const TextStyle(color: AppColors.white),
                        ),
                        subtitle: Text(
                          '${(ride.totalDistanceMeters / 1000).toStringAsFixed(1)} km · '
                          '${ride.averageSpeedKmh.toStringAsFixed(1)} km/h · '
                          '${ride.duration.inMinutes} min',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.white54,
                        ),
                        onTap: () => _openRideSummary(ride.rideId),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
