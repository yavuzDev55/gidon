import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../core/permissions/location_permission_handler.dart';
import '../../services/location/gps_point.dart';
import '../../services/location/isar_service.dart';
import '../../services/location/location_stream_service.dart';
import '../../services/location/ride_stats_calculator.dart';
import '../../services/scoring/score_calculator.dart';
import '../../theme/app_colors.dart';
import '../map/map_controls_pill.dart';
import 'live_route_map_view.dart';
import 'recording_stop_control.dart';
import 'ride_summary_screen.dart';
import '../progression/progression_result_screen.dart';
import '../map/geocoding_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Hosts both the idle "browse the map, start a ride" UI and the
/// active recording UI, switching between them based on whether a
/// ride is currently in progress.
class LiveTrackingScreen extends StatefulWidget {
  final IsarService isarService;

  const LiveTrackingScreen({super.key, required this.isarService});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  final LocationStreamService _locationStreamService = LocationStreamService();
  final MapController_ _mapControllerHolder = MapController_();

  Position? _currentPosition;
  String? _errorMessage;
  bool _isRideActive = false;
  String? _currentRideId;
  Timer? _countRefreshTimer;

  int _recordedPointsCount = 0;
  double _totalDistanceMeters = 0;
  double _averageSpeedKmh = 0;
  double _maxSpeedKmh = 0;
  double _accelerationMs2 = 0;
  List<GpsPoint> _recordedPoints = [];
  bool _isPaused = false;

  List<MultiplierInfo> _activeMultipliers = [];
  double _combinedMultiplier = 1;

  MapLayerStyle _mapLayerStyle = MapLayerStyle.standard;
  LatLng? _searchedLocation;
  final TextEditingController _searchController = TextEditingController();
  List<GeocodingResult> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    try {
      await LocationPermissionHandler.ensurePermissions();
      _locationStreamService.start();
      _locationStreamService.positionStream.listen(
        (position) => setState(() => _currentPosition = position),
        onError: (error) => setState(() => _errorMessage = error.toString()),
      );
    } catch (error) {
      setState(() => _errorMessage = error.toString());
    }
  }

  Future<void> _refreshRecordedPointsCount(String rideId) async {
    final points = await widget.isarService.getPointsForRide(rideId);
    final distance = RideStatsCalculator.totalDistanceMeters(points);
    final avgSpeed = RideStatsCalculator.averageSpeedMetersPerSecond(points);
    final maxSpeed = RideStatsCalculator.maxSpeedMetersPerSecond(points);
    final acceleration =
        RideStatsCalculator.currentAccelerationMetersPerSecondSquared(points);
    final multiplierStatus = ScoreCalculator.evaluate(points);

    final isPaused =
        points.isNotEmpty &&
        (points.last.speed * 3.6) < 5.0 &&
        points.length > 1;

    if (mounted) {
      setState(() {
        _recordedPointsCount = points.length;
        _totalDistanceMeters = distance;
        _averageSpeedKmh = avgSpeed * 3.6;
        _maxSpeedKmh = maxSpeed * 3.6;
        _accelerationMs2 = acceleration;
        _recordedPoints = points;
        _activeMultipliers = multiplierStatus.currentActiveMultipliers;
        _combinedMultiplier = multiplierStatus.currentCombinedMultiplier;
        _isPaused = isPaused;
      });
    }
  }

  void _toggleRide() async {
    final service = FlutterBackgroundService();

    if (_isRideActive) {
      final rideId = _currentRideId;
      service.invoke('stopRide');
      WakelockPlus.disable();
      _countRefreshTimer?.cancel();

      setState(() {
        _isRideActive = false;
        _currentRideId = null;
        _recordedPoints = [];
        _recordedPointsCount = 0;
        _totalDistanceMeters = 0;
        _averageSpeedKmh = 0;
        _maxSpeedKmh = 0;
        _accelerationMs2 = 0;
        _activeMultipliers = [];
        _combinedMultiplier = 1;
        _isPaused = false;
      });

      if (rideId != null) {
        final points = await widget.isarService.getPointsForRide(rideId);
        final summary = RideSummary.fromPoints(points);

        const minDurationSeconds = 30;
        const minDistanceMeters = 250.0;

        final isTooShort =
            summary.duration.inSeconds < minDurationSeconds ||
            summary.totalDistanceMeters < minDistanceMeters;

        if (isTooShort) {
          await widget.isarService.deletePointsForRide(rideId);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ride too short — not saved.')),
            );
          }
          return;
        }

        final scoreResult = ScoreCalculator.evaluate(points);

        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProgressionResultScreen(
                scoreResult: scoreResult,
                summary: summary,
                points: points,
                isarService: widget.isarService,
                rideId: rideId,
              ),
            ),
          );
        }
      }
    } else {
      final rideId = DateTime.now().toUtc().toIso8601String();
      final wasAlreadyRunning = await service.isRunning();

      if (!wasAlreadyRunning) {
        await service.startService();
        await service
            .on('ready')
            .first
            .timeout(
              const Duration(seconds: 8),
              onTimeout: () => <String, dynamic>{},
            );
      }

      service.invoke('startRide', {'rideId': rideId});

      _countRefreshTimer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => _refreshRecordedPointsCount(rideId),
      );

      setState(() {
        _isRideActive = true;
        _currentRideId = rideId;
        _recordedPointsCount = 0;
      });

      WakelockPlus.enable();
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    final results = await GeocodingService.search(query);
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  void _selectSearchResult(GeocodingResult result) {
    setState(() {
      _searchedLocation = result.position;
      _searchResults = [];
      _searchController.text = result.displayName;
    });
    _mapControllerHolder.moveTo(result.position, zoom: 15);
    FocusScope.of(context).unfocus();
  }

  void _toggleLayerStyle() {
    setState(() {
      _mapLayerStyle = _mapLayerStyle == MapLayerStyle.standard
          ? MapLayerStyle.topographic
          : MapLayerStyle.standard;
    });
  }

  Future<void> _showDiscardConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard ride?'),
        content: const Text(
          'This will delete the recorded ride. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep recording'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final rideId = _currentRideId;
      final service = FlutterBackgroundService();
      service.invoke('stopRide');
      WakelockPlus.disable();
      _countRefreshTimer?.cancel();

      if (rideId != null) {
        await widget.isarService.deletePointsForRide(rideId);
      }

      setState(() {
        _isRideActive = false;
        _currentRideId = null;
        _recordedPoints = [];
        _recordedPointsCount = 0;
        _totalDistanceMeters = 0;
        _averageSpeedKmh = 0;
        _maxSpeedKmh = 0;
        _accelerationMs2 = 0;
        _activeMultipliers = [];
        _combinedMultiplier = 1;
        _isPaused = false;
      });
    }
  }

  @override
  void dispose() {
    _countRefreshTimer?.cancel();
    _locationStreamService.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    return _isRideActive
        ? _buildRecordingView(context)
        : _buildIdleMapView(context);
  }

  /// Idle state: full-screen map, search bar, and the prominent
  /// yellow start button (bottom-right).
  Widget _buildIdleMapView(BuildContext context) {
    final currentLatLng = _currentPosition != null
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : null;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            LiveRouteMapView(
              points: const [],
              currentPosition: currentLatLng,
              controllerHolder: _mapControllerHolder,
              layerStyle: _mapLayerStyle,
              searchedLocation: _searchedLocation,
            ),
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.black,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search,
                          color: AppColors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: AppColors.white),
                            decoration: InputDecoration(
                              hintText: 'Search location',
                              hintStyle: TextStyle(
                                color: AppColors.white.withValues(alpha: 0.5),
                              ),
                              border: InputBorder.none,
                            ),
                            onSubmitted: _performSearch,
                          ),
                        ),
                        if (_isSearching)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.yellow,
                            ),
                          )
                        else if (_searchController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() {
                                _searchResults = [];
                                _searchedLocation = null;
                              });
                            },
                            child: const Icon(
                              Icons.close,
                              color: AppColors.white,
                              size: 18,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (_searchResults.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        color: AppColors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: _searchResults.map((result) {
                          return ListTile(
                            dense: true,
                            leading: const Icon(
                              Icons.place_outlined,
                              color: AppColors.yellow,
                            ),
                            title: Text(
                              result.displayName,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 13,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => _selectSearchResult(result),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
            Positioned(
              right: 16,
              bottom: 140,
              child: MapControlsPill(
                onRecenter: () => _mapControllerHolder.recenter(currentLatLng),
                onToggleLayers: _toggleLayerStyle,
                onToggleCompass: () => _mapControllerHolder.resetRotation(),
              ),
            ),
            Positioned(
              right: 24,
              bottom: 24,
              child: GestureDetector(
                onTap: _toggleRide,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: AppColors.yellow,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: AppColors.black,
                    size: 36,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Active recording state: stats panel, map, map controls, and the
  /// expandable stop control (positioned above the always-on radial
  /// nav menu, which lives independently in MainNavigationScreen).
  Widget _buildRecordingView(BuildContext context) {
    final currentLatLng = _currentPosition != null
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : null;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Stack(
          children: [
            LiveRouteMapView(
              points: _recordedPoints,
              currentPosition: currentLatLng,
              controllerHolder: _mapControllerHolder,
            ),
            Positioned(top: 12, left: 16, right: 16, child: _buildStatsPanel()),
            Positioned(
              right: 16,
              bottom: 100,
              child: MapControlsPill(
                onRecenter: () => _mapControllerHolder.recenter(currentLatLng),
                onToggleLayers: _toggleLayerStyle,
                onToggleCompass: () => _mapControllerHolder.resetRotation(),
              ),
            ),
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Center(
                child: RecordingStopControl(
                  onFinish: _toggleRide,
                  onCancel: _showDiscardConfirmation,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatLabel(
                      label: 'Distance:',
                      value: (_totalDistanceMeters / 1000).toStringAsFixed(2),
                      unit: 'km',
                    ),
                    const SizedBox(height: 6),
                    _StatLabel(
                      label: 'Time:',
                      value: _recordedPoints.isEmpty
                          ? '0'
                          : '${DateTime.now().difference(_recordedPoints.first.timestamp.toLocal()).inMinutes}',
                      unit: 'min',
                    ),
                  ],
                ),
              ),
              Container(
                width: 96,
                height: 96,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: const BoxDecoration(
                  color: AppColors.yellow,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ((_currentPosition?.speed ?? 0) * 3.6).toStringAsFixed(
                          0,
                        ),
                        style: const TextStyle(
                          color: AppColors.black,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                      const Text(
                        'kmph',
                        style: TextStyle(color: AppColors.black, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _StatLabel(
                      label: 'Average Speed:',
                      value: _averageSpeedKmh.toStringAsFixed(1),
                      unit: 'kmph',
                      alignEnd: true,
                    ),
                    const SizedBox(height: 6),
                    _StatLabel(
                      label: 'Max Speed:',
                      value: _maxSpeedKmh.toStringAsFixed(1),
                      unit: 'kmph',
                      alignEnd: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.yellow,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                _isPaused
                    ? 'Auto-Pause'
                    : _combinedMultiplier > 1
                    ? 'x${_combinedMultiplier.toStringAsFixed(0)} ${_activeMultipliers.map((m) => m.displayName).join(' + ')}'
                    : 'Recording',
                style: const TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatLabel extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final bool alignEnd;

  const _StatLabel({
    required this.label,
    required this.value,
    required this.unit,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              unit,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }
}
