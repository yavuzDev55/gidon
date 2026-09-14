import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../services/location/gps_point.dart';
import '../../services/location/ride_stats_calculator.dart';
import '../../services/location/route_polyline_builder.dart';
import '../../services/routing/route_plan_logic.dart';
import '../../services/routing/route_waypoint.dart';
import '../../theme/app_colors.dart';

enum MapLayerStyle { cycling, terrain, satellite }

/// Lets ancestor widgets (map control buttons, search bar) trigger
/// actions on the map without needing direct access to flutter_map's
/// own MapController.
class RideMapController {
  VoidCallback? _recenterAndAlignCallback;
  void Function(LatLng position, {double? zoom})? _moveToCallback;

  void _attach({
    required VoidCallback recenterAndAlign,
    required void Function(LatLng, {double? zoom}) moveTo,
  }) {
    _recenterAndAlignCallback = recenterAndAlign;
    _moveToCallback = moveTo;
  }

  void _detach() {
    _recenterAndAlignCallback = null;
    _moveToCallback = null;
  }

  /// Smoothly moves back to the current GPS position, resets to
  /// heading-up rotation (or north if not moving), resumes auto-follow,
  /// and clears any manual rotation override.
  void recenterAndAlign() => _recenterAndAlignCallback?.call();

  void moveTo(LatLng position, {double? zoom}) =>
      _moveToCallback?.call(position, zoom: zoom);
}

/// Renders the ride's route (or an idle map view when [points] is
/// empty), auto-following the rider's position and, while following,
/// auto-rotating to match the direction of travel ("heading up") and
/// biasing the view ahead of the rider based on speed.
class LiveRouteMapView extends StatefulWidget {
  final List<GpsPoint> points;
  final LatLng? currentPosition;
  final RideMapController? controllerHolder;
  final MapLayerStyle layerStyle;
  final LatLng? searchedLocation;
  final List<LatLng> plannedPolyline;
  final List<RouteWaypoint> plannedWaypoints;
  final void Function(LatLng point)? onMapTap;

  /// Compass heading in degrees (0-360, 0 = north), from the device's
  /// GPS course-over-ground. Null or unreliable when stationary.
  final double? headingDegrees;

  /// Current speed in km/h — drives the look-ahead offset and gates
  /// whether heading-based rotation is applied (ignored at very low
  /// speed, where GPS heading is noisy).
  final double? speedKmh;

  const LiveRouteMapView({
    super.key,
    required this.points,
    required this.currentPosition,
    this.controllerHolder,
    this.layerStyle = MapLayerStyle.cycling,
    this.searchedLocation,
    this.plannedPolyline = const [],
    this.plannedWaypoints = const [],
    this.onMapTap,
    this.headingDegrees,
    this.speedKmh,
  });

  @override
  State<LiveRouteMapView> createState() => _LiveRouteMapViewState();
}

class _LiveRouteMapViewState extends State<LiveRouteMapView>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();

  bool _isFollowingUser = true;
  bool _manualRotationOverride = false;
  int _resumeFollowToken = 0;
  LatLng? _displayedPosition;
  LatLng? _lastKnownCenter;
  double? _lastKnownRotationDeg;
  AnimationController? _moveAnimController;

  static const _minMovementMeters = 5.0;
  static const _panGestureThresholdMeters = 3.0;
  static const _rotationGestureThresholdDeg = 3.0;
  static const _earthRadiusMeters = 6371000.0;
  static const _defaultFollowZoom = 17.0;
  static const _headingActiveSpeedKmh = 3.0;
  static const _resumeFollowDelay = Duration(seconds: 5);

  // Look-ahead tuning: at higher speed, the view center shifts ahead
  // of the rider in the direction of travel, up to a capped distance.
  static const _lookAheadSeconds = 5.0;
  static const _maxLookAheadMeters = 150.0;

  @override
  void initState() {
    super.initState();
    widget.controllerHolder?._attach(
      recenterAndAlign: _handleRecenterAndAlign,
      moveTo: (position, {zoom}) {
        setState(() => _isFollowingUser = false);
        _animatedMapMove(
          position,
          zoom ?? _mapController.camera.zoom,
          rotation: 0,
        );
      },
    );
  }

  @override
  void dispose() {
    widget.controllerHolder?._detach();
    _moveAnimController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LiveRouteMapView oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newPosition = widget.currentPosition;
    if (newPosition == null) return;

    final isRealMovement =
        _displayedPosition == null ||
        _distanceMeters(_displayedPosition!, newPosition) >= _minMovementMeters;

    if (isRealMovement) {
      _displayedPosition = newPosition;
    }

    if (_isFollowingUser && isRealMovement) {
      final speedKmh = widget.speedKmh ?? 0;
      final heading = widget.headingDegrees;

      final targetCenter = _computeFollowTarget(newPosition, heading, speedKmh);

      // Only touch rotation if we're allowed to (no manual override)
      // and moving fast enough for heading to be trustworthy —
      // otherwise leave whatever rotation the map currently has.
      final targetRotation =
          (!_manualRotationOverride &&
              heading != null &&
              speedKmh >= _headingActiveSpeedKmh)
          ? -heading // NOTE: flip sign here to `heading` if the
          // map appears to rotate the wrong way.
          : null;

      _animatedMapMove(
        targetCenter,
        _mapController.camera.zoom,
        rotation: targetRotation,
        duration: const Duration(milliseconds: 900),
      );
    }
  }

  /// Offsets [position] forward along [headingDegrees] by a distance
  /// proportional to [speedKmh] (capped), so the visible map leans
  /// into what's ahead rather than centering exactly on the rider.
  LatLng _computeFollowTarget(
    LatLng position,
    double? headingDegrees,
    double speedKmh,
  ) {
    if (headingDegrees == null) return position;

    final speedMs = speedKmh / 3.6;
    final lookAheadMeters = (speedMs * _lookAheadSeconds).clamp(
      0.0,
      _maxLookAheadMeters,
    );

    if (lookAheadMeters <= 0) return position;

    return _destinationPoint(position, headingDegrees, lookAheadMeters);
  }

  void _handleRecenterAndAlign() {
    _resumeFollowToken++;
    setState(() {
      _isFollowingUser = true;
      _manualRotationOverride = false;
    });

    final target = _displayedPosition ?? widget.currentPosition;
    if (target == null) return;

    final heading = widget.headingDegrees;
    final speedKmh = widget.speedKmh ?? 0;
    final rotation = (heading != null && speedKmh >= _headingActiveSpeedKmh)
        ? -heading
        : 0.0;
    final followTarget = _computeFollowTarget(target, heading, speedKmh);

    _animatedMapMove(followTarget, _defaultFollowZoom, rotation: rotation);
  }

  void _animatedMapMove(
    LatLng destination,
    double destZoom, {
    double? rotation,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    _moveAnimController?.dispose();

    final camera = _mapController.camera;
    final latTween = Tween<double>(
      begin: camera.center.latitude,
      end: destination.latitude,
    );
    final lngTween = Tween<double>(
      begin: camera.center.longitude,
      end: destination.longitude,
    );
    final zoomTween = Tween<double>(begin: camera.zoom, end: destZoom);

    Tween<double>? rotationTween;
    if (rotation != null) {
      // Always animate through the SHORTEST angular path (e.g. 350°
      // to 10° should turn forward through 0°, not backward through 180°).
      var delta = (rotation - camera.rotation) % 360;
      if (delta > 180) delta -= 360;
      if (delta < -180) delta += 360;
      rotationTween = Tween<double>(
        begin: camera.rotation,
        end: camera.rotation + delta,
      );
    }

    final controller = AnimationController(vsync: this, duration: duration);
    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOutCubic,
    );
    _moveAnimController = controller;

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
      if (rotationTween != null) {
        _mapController.rotate(rotationTween.evaluate(animation));
      }
    });

    controller.forward();
  }

  double _distanceMeters(LatLng a, LatLng b) {
    double toRad(double deg) => deg * (pi / 180);
    final lat1 = toRad(a.latitude);
    final lat2 = toRad(b.latitude);
    final deltaLat = toRad(b.latitude - a.latitude);
    final deltaLon = toRad(b.longitude - a.longitude);
    final h =
        sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1) * cos(lat2) * sin(deltaLon / 2) * sin(deltaLon / 2);
    final c = 2 * atan2(sqrt(h), sqrt(1 - h));
    return _earthRadiusMeters * c;
  }

  /// Standard "destination point given distance and bearing" formula.
  LatLng _destinationPoint(
    LatLng origin,
    double bearingDegrees,
    double distanceMeters,
  ) {
    final bearingRad = bearingDegrees * pi / 180;
    final lat1 = origin.latitude * pi / 180;
    final lon1 = origin.longitude * pi / 180;
    final angularDistance = distanceMeters / _earthRadiusMeters;

    final lat2 = asin(
      sin(lat1) * cos(angularDistance) +
          cos(lat1) * sin(angularDistance) * cos(bearingRad),
    );
    final lon2 =
        lon1 +
        atan2(
          sin(bearingRad) * sin(angularDistance) * cos(lat1),
          cos(angularDistance) - sin(lat1) * sin(lat2),
        );

    return LatLng(lat2 * 180 / pi, lon2 * 180 / pi);
  }

  /// Distinguishes pan (breaks position-following) from rotate
  /// (breaks only auto-heading-rotation, following continues) — both
  /// tracked independently since a single gesture could do either.
  void _onMapEvent(MapEvent event) {
    if (event is! MapEventMove ||
        event.source == MapEventSource.mapController) {
      _lastKnownCenter = event.camera.center;
      _lastKnownRotationDeg = event.camera.rotation;
      return;
    }

    final previousCenter = _lastKnownCenter;
    final previousRotation = _lastKnownRotationDeg;
    _lastKnownCenter = event.camera.center;
    _lastKnownRotationDeg = event.camera.rotation;

    if (previousCenter != null) {
      final moved = _distanceMeters(previousCenter, event.camera.center);
      if (moved > _panGestureThresholdMeters) {
        _pauseFollowingTemporarily();
      }
    }

    if (previousRotation != null && !_manualRotationOverride) {
      final rotationDelta = (event.camera.rotation - previousRotation).abs();
      if (rotationDelta > _rotationGestureThresholdDeg) {
        setState(() => _manualRotationOverride = true);
      }
    }
  }

  void _pauseFollowingTemporarily() {
    setState(() => _isFollowingUser = false);
    final myToken = ++_resumeFollowToken;
    Future.delayed(_resumeFollowDelay, () {
      if (mounted && myToken == _resumeFollowToken) {
        setState(() => _isFollowingUser = true);
      }
    });
  }

  String get _tileUrlTemplate {
    switch (widget.layerStyle) {
      case MapLayerStyle.cycling:
        return 'https://{s}.tile-cyclosm.openstreetmap.fr/cyclosm/{z}/{x}/{y}.png';
      case MapLayerStyle.terrain:
        return 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png';
      case MapLayerStyle.satellite:
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/'
            'World_Imagery/MapServer/tile/{z}/{y}/{x}';
    }
  }

  /// The highest zoom level each provider actually has tiles for.
  /// Beyond this, flutter_map will stretch the last available tile
  /// instead of requesting one that doesn't exist (which would
  /// otherwise show blank or a "No data yet" placeholder image).
  int get _maxNativeZoomForLayer {
    switch (widget.layerStyle) {
      case MapLayerStyle.cycling:
        return 20;
      case MapLayerStyle.terrain:
        return 17;
      case MapLayerStyle.satellite:
        // Esri's actual coverage varies a lot by region — dense
        // cities often have detail past 18, rural areas much less.
        // 17 is a safe middle ground that avoids placeholder tiles
        // in most populated areas; very remote areas may still hit
        // Esri's own imagery limit before this (see note below).
        return 17;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredPoints = RideStatsCalculator.filterForDisplay(widget.points);
    final routePoints = filteredPoints
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    final initialCenter =
        _displayedPosition ?? routePoints.firstOrNull ?? const LatLng(0, 0);

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: initialCenter,
            initialZoom: _defaultFollowZoom,
            onMapEvent: _onMapEvent,
            onTap: widget.onMapTap == null
                ? null
                : (tapPosition, point) => widget.onMapTap!(point),
            maxZoom: 19,
            minZoom: 3,
          ),
          children: [
            TileLayer(
              urlTemplate: _tileUrlTemplate,
              userAgentPackageName: 'com.gidon.app',
              subdomains: widget.layerStyle == MapLayerStyle.satellite
                  ? const []
                  : const ['a', 'b', 'c'],
              maxNativeZoom: _maxNativeZoomForLayer,
              maxZoom: 19,
            ),
            if (widget.plannedPolyline.length >= 2)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: widget.plannedPolyline,
                    strokeWidth: 5,
                    color: AppColors.plannedRoute.withValues(alpha: 0.9),
                    borderStrokeWidth: 2,
                    borderColor: AppColors.black,
                  ),
                ],
              ),
            if (filteredPoints.length >= 2)
              PolylineLayer(
                polylines: RoutePolylineBuilder.buildFlowingGradientPolylines(
                  filteredPoints,
                ),
              ),
            if (widget.plannedWaypoints.isNotEmpty)
              MarkerLayer(
                markers: [
                  for (var i = 0; i < widget.plannedWaypoints.length; i++)
                    Marker(
                      point: widget.plannedWaypoints[i].position,
                      width: 32,
                      height: 32,
                      child: _WaypointMarker(
                        number: i + 1,
                        isNext:
                            i ==
                            RoutePlanLogic.nextIncompleteIndex(
                              widget.plannedWaypoints,
                            ),
                        isCompleted: widget.plannedWaypoints[i].completed,
                      ),
                    ),
                ],
              ),
            if (_displayedPosition != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _displayedPosition!,
                    width: 24,
                    height: 24,
                    child: const Icon(
                      Icons.circle,
                      color: Colors.red,
                      size: 16,
                    ),
                  ),
                ],
              ),
            if (widget.searchedLocation != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: widget.searchedLocation!,
                    width: 36,
                    height: 36,
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.black,
                      size: 36,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class _WaypointMarker extends StatelessWidget {
  final int number;
  final bool isNext;
  final bool isCompleted;

  const _WaypointMarker({
    required this.number,
    required this.isNext,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final background = isCompleted
        ? Colors.white54
        : isNext
        ? AppColors.yellow
        : AppColors.black;
    final foreground = isNext && !isCompleted
        ? AppColors.black
        : AppColors.white;

    return Container(
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.white, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
