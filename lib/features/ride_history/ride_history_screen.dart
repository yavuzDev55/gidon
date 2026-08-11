import 'package:flutter/material.dart';
import '../../services/location/isar_service.dart';
import '../../services/location/ride_stats_calculator.dart';
import '../live_tracking/ride_summary_screen.dart';

/// Displays the list of previously recorded rides, most recent first.
class RideHistoryScreen extends StatefulWidget {
  final IsarService isarService;

  const RideHistoryScreen({super.key, required this.isarService});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  late Future<List<RideOverview>> _ridesFuture;

  @override
  void initState() {
    super.initState();
    _ridesFuture = widget.isarService.getAllRideOverviews();
  }

  Future<void> _refresh() async {
    setState(() {
      _ridesFuture = widget.isarService.getAllRideOverviews();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ride History')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<RideOverview>>(
          future: _ridesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final rides = snapshot.data ?? [];

            if (rides.isEmpty) {
              return const Center(child: Text('No rides recorded yet.'));
            }

            return ListView.builder(
              itemCount: rides.length,
              itemBuilder: (context, index) {
                final ride = rides[index];
                return ListTile(
                  leading: const Icon(Icons.directions_bike),
                  title: Text(
                    ride.name?.isNotEmpty == true
                        ? ride.name!
                        : _formatDate(ride.startTime),
                  ),
                  subtitle: Text(
                    ride.name?.isNotEmpty == true
                        ? '${_formatDate(ride.startTime)} • ${ride.pointCount} points'
                        : '${ride.pointCount} points recorded',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openRideSummary(ride.rideId),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime utcTime) {
    final local = utcTime.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}
