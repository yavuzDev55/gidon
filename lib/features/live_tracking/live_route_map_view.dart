import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../services/location/gps_point.dart';
import '../../services/location/ride_stats_calculator.dart';

enum MapLayerStyle { cycling, terrain }

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

  /// Smoothly moves back to the current GPS position at the default
  /// follow zoom, resets rotation to north, and resumes auto-follow.
  void recenterAndAlign() => _recenterAndAlignCallback?.call();

  void moveTo(LatLng position, {double? zoom}) =>
      _moveToCallback?.call(position, zoom: zoom);
}

/// Renders the ride's route (or an idle map view when [points] is
/// empty), auto-following the rider's position. Filters GPS jitter so
/// the route/marker don't jump when stationary or the phone shakes.
class LiveRouteMapView extends StatefulWidget {
  final List<GpsPoint> points;
  final LatLng? currentPosition;
  final RideMapController? controllerHolder;
  final MapLayerStyle layerStyle;
  final LatLng? searchedLocation;

  const LiveRouteMapView({
    super.key,
    required this.points,
    required this.currentPosition,
    this.controllerHolder,
    this.layerStyle = MapLayerStyle.cycling,
    this.searchedLocation,
  });

  @override
  State<LiveRouteMapView> createState() => _LiveRouteMapViewState();
}

class _LiveRouteMapViewState extends State<LiveRouteMapView>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();

  bool _isFollowingUser = true;
  int _resumeFollowToken = 0;
  LatLng? _displayedPosition;
  LatLng? _lastKnownCenter;
  AnimationController? _moveAnimController;

  static const _minMovementMeters = 5.0;
  static const _panGestureThresholdMeters = 3.0;
  static const _earthRadiusMeters = 6371000.0;
  static const _defaultFollowZoom = 17.0;
  static const _resumeFollowDelay = Duration(seconds: 5);

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

    final shouldAccept =
        _displayedPosition == null ||
        _distanceMeters(_displayedPosition!, newPosition) >= _minMovementMeters;

    if (shouldAccept) {
      _displayedPosition = newPosition;
      if (_isFollowingUser) {
        // Keep whatever zoom the user currently has (e.g. if they
        // pinch-zoomed while following), don't reset it.
        _animatedMapMove(
          newPosition,
          _mapController.camera.zoom,
          duration: const Duration(milliseconds: 900),
        );
      }
    }
  }

  void _handleRecenterAndAlign() {
    _resumeFollowToken++;
    setState(() => _isFollowingUser = true);
    final target = _displayedPosition ?? widget.currentPosition;
    if (target != null) {
      _animatedMapMove(target, _defaultFollowZoom, rotation: 0);
    }
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
    final rotationTween = rotation == null
        ? null
        : Tween<double>(begin: camera.rotation, end: rotation);

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

  /// Distinguishes a real pan/drag from a pinch-zoom that keeps the
  /// center roughly in place. We track the center ourselves across
  /// consecutive move events (flutter_map's MapEventMove doesn't
  /// expose the "previous" center directly).
  void _onMapEvent(MapEvent event) {
    if (event is! MapEventMove ||
        event.source == MapEventSource.mapController) {
      _lastKnownCenter = event.camera.center;
      return;
    }

    final previousCenter = _lastKnownCenter;
    _lastKnownCenter = event.camera.center;

    if (previousCenter == null) return;

    final moved = _distanceMeters(previousCenter, event.camera.center);
    if (moved > _panGestureThresholdMeters) {
      _pauseFollowingTemporarily();
    }
    // Otherwise: zoom-only gesture — following continues, and the
    // next location update will simply keep using this new zoom
    // level (see didUpdateWidget above).
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
        // CyclOSM: shows bike lanes, cycle tracks, and road types
        // relevant to cyclists.
        return 'https://{s}.tile-cyclosm.openstreetmap.fr/cyclosm/{z}/{x}/{y}.png';
      case MapLayerStyle.terrain:
        // OpenTopoMap: elevation contours and terrain features, for
        // seeing what's around you.
        return 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png';
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
          ),
          children: [
            TileLayer(
              urlTemplate: _tileUrlTemplate,
              userAgentPackageName: 'com.gidon.app',
              subdomains: const ['a', 'b', 'c'],
            ),
            if (routePoints.length >= 2)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routePoints,
                    strokeWidth: 4,
                    color: Colors.blue,
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
