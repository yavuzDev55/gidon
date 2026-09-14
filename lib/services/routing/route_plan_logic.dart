import 'package:latlong2/latlong.dart';

import 'route_waypoint.dart';

/// Pure rules for waypoint order, arrival, and when to ask the
/// router for a new line. Kept out of widgets so it can be tested
/// without Flutter or HTTP.
class RoutePlanLogic {
  RoutePlanLogic._();

  /// Distance at which the rider is treated as having reached the
  /// next stop. Wide enough for GPS jitter, tight enough not to
  /// complete a stop from the next street over.
  static const double arrivalRadiusMeters = 40;

  /// Ignore GPS updates closer than this to the last routed origin
  /// so we do not hammer the public routing server.
  static const double minRerouteMoveMeters = 25;

  static const Duration minRerouteInterval = Duration(seconds: 8);

  static const Distance _distance = Distance();

  static int nextIncompleteIndex(List<RouteWaypoint> waypoints) {
    return waypoints.indexWhere((waypoint) => !waypoint.completed);
  }

  static RouteWaypoint? nextIncomplete(List<RouteWaypoint> waypoints) {
    final index = nextIncompleteIndex(waypoints);
    if (index < 0) return null;
    return waypoints[index];
  }

  /// Completes only the current next stop when the rider is inside
  /// [arrivalRadiusMeters]. Later stops are not auto-completed by
  /// proximity — the rider skips or reorders those instead.
  static List<RouteWaypoint> completeIfArrived({
    required List<RouteWaypoint> waypoints,
    required LatLng position,
  }) {
    final index = nextIncompleteIndex(waypoints);
    if (index < 0) return waypoints;

    final next = waypoints[index];
    final meters = _distance.as(
      LengthUnit.Meter,
      position,
      next.position,
    );
    if (meters > arrivalRadiusMeters) return waypoints;

    final updated = List<RouteWaypoint>.from(waypoints);
    updated[index] = next.copyWith(completed: true);
    return updated;
  }

  static List<RouteWaypoint> skipNext(List<RouteWaypoint> waypoints) {
    final index = nextIncompleteIndex(waypoints);
    if (index < 0) return waypoints;

    final updated = List<RouteWaypoint>.from(waypoints);
    updated[index] = updated[index].copyWith(completed: true);
    return updated;
  }

  /// Matches [ReorderableListView] index conventions: when the drop
  /// index is after the drag index, Flutter reports a value one slot
  /// too high.
  static List<RouteWaypoint> reorder(
    List<RouteWaypoint> waypoints,
    int oldIndex,
    int newIndex,
  ) {
    final updated = List<RouteWaypoint>.from(waypoints);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = updated.removeAt(oldIndex);
    updated.insert(newIndex, item);
    return updated;
  }

  /// Stops sent to the bike router: current location (when known)
  /// then every incomplete waypoint in list order. Completed stops
  /// stay off the live line.
  static List<LatLng> routingStops({
    required List<RouteWaypoint> waypoints,
    LatLng? origin,
  }) {
    final remaining = waypoints
        .where((waypoint) => !waypoint.completed)
        .map((waypoint) => waypoint.position)
        .toList();

    if (origin == null) return remaining;
    if (remaining.isEmpty) return const [];
    return [origin, ...remaining];
  }

  static bool shouldReroute({
    required LatLng current,
    required LatLng? lastRoutedFrom,
    required DateTime now,
    required DateTime? lastRoutedAt,
  }) {
    if (lastRoutedFrom == null || lastRoutedAt == null) return true;

    final movedMeters = _distance.as(
      LengthUnit.Meter,
      lastRoutedFrom,
      current,
    );
    if (movedMeters < minRerouteMoveMeters) return false;

    return now.difference(lastRoutedAt) >= minRerouteInterval;
  }
}
