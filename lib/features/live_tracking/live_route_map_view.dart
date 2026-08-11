import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../services/location/gps_point.dart';
import '../../services/location/ride_stats_calculator.dart';

/// Which map tile style is currently shown. Topographic shows
/// elevation contour lines — useful for a cycling app.
enum MapLayerStyle { standard, topographic }

/// Lets ancestor widgets (map control buttons, search bar) trigger
/// actions on the map without needing direct access to flutter_map's
/// own MapController.
class MapController_ {
  VoidCallback? _recenterCallback;
  void Function(LatLng position, {double? zoom})? _moveToCallback;
  VoidCallback? _resetRotationCallback;

  void _attach({
    required VoidCallback recenter,
    required void Function(LatLng, {double? zoom}) moveTo,
    required VoidCallback resetRotation,
  }) {
    _recenterCallback = recenter;
    _moveToCallback = moveTo;
    _resetRotationCallback = resetRotation;
  }

  void _detach() {
    _recenterCallback = null;
    _moveToCallback = null;
    _resetRotationCallback = null;
  }

  void recenter(LatLng? position) => _recenterCallback?.call();
  void moveTo(LatLng position, {double? zoom}) =>
      _moveToCallback?.call(position, zoom: zoom);
  void resetRotation() => _resetRotationCallback?.call();
}

/// Renders the ride's route (or an idle map view when [points] is
/// empty), auto-following the rider's position. Filters GPS jitter so
/// the route/marker don't jump when stationary or the phone shakes.
class LiveRouteMapView extends StatefulWidget {
  final List<GpsPoint> points;
  final LatLng? currentPosition;
  final MapController_? controllerHolder;
  final MapLayerStyle layerStyle;
  final LatLng? searchedLocation;

  const LiveRouteMapView({
    super.key,
    required this.points,
    required this.currentPosition,
    this.controllerHolder,
    this.layerStyle = MapLayerStyle.standard,
    this.searchedLocation,
  });

  @override
  State<LiveRouteMapView> createState() => _LiveRouteMapViewState();
}

class _LiveRouteMapViewState extends State<LiveRouteMapView> {
  final MapController _mapController = MapController();

  bool _isFollowingUser = true;
  int _resumeFollowToken = 0;
  LatLng? _displayedPosition;

  static const _minMovementMeters = 5.0;
  static const _earthRadiusMeters = 6371000.0;
  static const _resumeFollowDelay = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    widget.controllerHolder?._attach(
      recenter: () {
        if (_displayedPosition != null) {
          _mapController.move(_displayedPosition!, _mapController.camera.zoom);
          setState(() => _isFollowingUser = true);
        }
      },
      moveTo: (position, {zoom}) {
        setState(() => _isFollowingUser = false);
        _mapController.move(position, zoom ?? _mapController.camera.zoom);
      },
      resetRotation: () => _mapController.rotate(0),
    );
  }

  @override
  void dispose() {
    widget.controllerHolder?._detach();
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
        _mapController.move(newPosition, _mapController.camera.zoom);
      }
    }
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

  void _onMapEvent(MapEvent event) {
    final isUserGesture =
        event is MapEventMove && event.source != MapEventSource.mapController;
    if (isUserGesture) _pauseFollowingTemporarily();
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
      case MapLayerStyle.standard:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
      case MapLayerStyle.topographic:
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
            initialZoom: 17,
            onMapEvent: _onMapEvent,
          ),
          children: [
            TileLayer(
              urlTemplate: _tileUrlTemplate,
              userAgentPackageName: 'com.gidon.app',
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
        if (!_isFollowingUser && widget.currentPosition != null)
          Positioned(
            bottom: 12,
            right: 12,
            child: FloatingActionButton.small(
              onPressed: () {
                _resumeFollowToken++;
                setState(() => _isFollowingUser = true);
              },
              child: const Icon(Icons.my_location),
            ),
          ),
      ],
    );
  }
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
