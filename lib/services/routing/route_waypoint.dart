import 'package:latlong2/latlong.dart';

/// A user-placed stop on a planned bike route. Completion is session
/// state only — saved routes store positions, not whether a stop was
/// reached during a previous ride.
class RouteWaypoint {
  final String id;
  final double latitude;
  final double longitude;
  final String label;
  final bool completed;

  const RouteWaypoint({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.label = '',
    this.completed = false,
  });

  LatLng get position => LatLng(latitude, longitude);

  RouteWaypoint copyWith({
    String? id,
    double? latitude,
    double? longitude,
    String? label,
    bool? completed,
  }) {
    return RouteWaypoint(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      label: label ?? this.label,
      completed: completed ?? this.completed,
    );
  }
}
