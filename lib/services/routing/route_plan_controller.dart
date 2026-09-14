import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import 'bike_routing_service.dart';
import 'route_plan_logic.dart';
import 'route_waypoint.dart';

/// Owns the in-memory planned route: stops, order, live line from
/// the rider's current position, and session completion.
class RoutePlanController extends ChangeNotifier {
  RoutePlanController({
    BikeRoutingService? routingService,
    DateTime Function()? clock,
  }) : _routingService = routingService ?? BikeRoutingService(),
       _clock = clock ?? DateTime.now;

  final BikeRoutingService _routingService;
  final DateTime Function() _clock;

  bool isPlanning = false;
  List<RouteWaypoint> waypoints = [];
  List<LatLng> polyline = [];
  double distanceMeters = 0;
  bool isRouting = false;
  String? errorMessage;
  String? loadedRouteId;
  String loadedRouteName = '';

  LatLng? _origin;
  LatLng? _lastRoutedFrom;
  DateTime? _lastRoutedAt;
  int _routeRequestId = 0;

  int get nextWaypointIndex => RoutePlanLogic.nextIncompleteIndex(waypoints);

  bool get hasWaypoints => waypoints.isNotEmpty;

  bool get allStopsReached =>
      waypoints.isNotEmpty && nextWaypointIndex < 0;

  void setPlanning(bool enabled) {
    if (isPlanning == enabled) return;
    isPlanning = enabled;
    notifyListeners();
  }

  void togglePlanning() => setPlanning(!isPlanning);

  void onLocationUpdated(LatLng? position) {
    _origin = position;
    if (position == null || waypoints.isEmpty) return;

    final afterArrival = RoutePlanLogic.completeIfArrived(
      waypoints: waypoints,
      position: position,
    );
    if (!_sameWaypoints(waypoints, afterArrival)) {
      waypoints = afterArrival;
      _requestRoute(force: true);
      notifyListeners();
      return;
    }

    if (RoutePlanLogic.shouldReroute(
      current: position,
      lastRoutedFrom: _lastRoutedFrom,
      now: _clock(),
      lastRoutedAt: _lastRoutedAt,
    )) {
      _requestRoute();
    }
  }

  void addWaypoint(LatLng position, {String label = ''}) {
    waypoints = [
      ...waypoints,
      RouteWaypoint(
        id: _clock().toUtc().microsecondsSinceEpoch.toString(),
        latitude: position.latitude,
        longitude: position.longitude,
        label: label,
      ),
    ];
    isPlanning = true;
    _requestRoute(force: true);
    notifyListeners();
  }

  void removeAt(int index) {
    if (index < 0 || index >= waypoints.length) return;
    waypoints = List.of(waypoints)..removeAt(index);
    if (waypoints.isEmpty) {
      polyline = [];
      distanceMeters = 0;
      loadedRouteId = null;
      loadedRouteName = '';
      errorMessage = null;
    } else {
      _requestRoute(force: true);
    }
    notifyListeners();
  }

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    waypoints = RoutePlanLogic.reorder(waypoints, oldIndex, newIndex);
    _requestRoute(force: true);
    notifyListeners();
  }

  void skipNext() {
    final updated = RoutePlanLogic.skipNext(waypoints);
    if (_sameWaypoints(waypoints, updated)) return;
    waypoints = updated;
    _requestRoute(force: true);
    notifyListeners();
  }

  void clear() {
    waypoints = [];
    polyline = [];
    distanceMeters = 0;
    errorMessage = null;
    loadedRouteId = null;
    loadedRouteName = '';
    _lastRoutedFrom = null;
    _lastRoutedAt = null;
    notifyListeners();
  }

  void loadSaved({
    required String routeId,
    required String name,
    required List<RouteWaypoint> savedWaypoints,
  }) {
    loadedRouteId = routeId;
    loadedRouteName = name;
    waypoints = savedWaypoints
        .map(
          (waypoint) => waypoint.copyWith(completed: false),
        )
        .toList();
    isPlanning = true;
    _requestRoute(force: true);
    notifyListeners();
  }

  void markSaved({required String routeId, required String name}) {
    loadedRouteId = routeId;
    loadedRouteName = name;
    notifyListeners();
  }

  Future<void> _requestRoute({bool force = false}) async {
    final stops = RoutePlanLogic.routingStops(
      waypoints: waypoints,
      origin: _origin,
    );

    if (stops.length < 2) {
      polyline = [];
      distanceMeters = 0;
      isRouting = false;
      errorMessage = null;
      notifyListeners();
      return;
    }

    if (!force &&
        _origin != null &&
        !RoutePlanLogic.shouldReroute(
          current: _origin!,
          lastRoutedFrom: _lastRoutedFrom,
          now: _clock(),
          lastRoutedAt: _lastRoutedAt,
        )) {
      return;
    }

    final requestId = ++_routeRequestId;
    isRouting = true;
    notifyListeners();

    try {
      final result = await _routingService.route(stops);
      if (requestId != _routeRequestId) return;
      polyline = result.points;
      distanceMeters = result.distanceMeters;
      errorMessage = null;
      _lastRoutedFrom = _origin;
      _lastRoutedAt = _clock();
    } catch (error) {
      if (requestId != _routeRequestId) return;
      errorMessage = error is BikeRoutingException
          ? error.message
          : 'Could not update route.';
    } finally {
      if (requestId == _routeRequestId) {
        isRouting = false;
        notifyListeners();
      }
    }
  }

  static bool _sameWaypoints(
    List<RouteWaypoint> a,
    List<RouteWaypoint> b,
  ) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id || a[i].completed != b[i].completed) {
        return false;
      }
    }
    return true;
  }
}
