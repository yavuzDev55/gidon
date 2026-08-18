import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../services/location/gps_point.dart';
import '../../services/location/ride_stats_calculator.dart';
import '../../services/location/route_polyline_builder.dart';

/// Renders a recorded ride's route as a line on an OpenStreetMap-based
/// map, automatically centered and zoomed to fit the whole route.
class RouteMapView extends StatelessWidget {
  final List<GpsPoint> points;

  const RouteMapView({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const Center(child: Text('No route data to display.'));
    }

    final filteredPoints = RideStatsCalculator.filterForDisplay(points);
    final routePoints = filteredPoints
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    final bounds = LatLngBounds.fromPoints(routePoints);

    return FlutterMap(
      options: MapOptions(
        initialCameraFit: CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(32),
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.gidon.app',
        ),
        PolylineLayer(
          polylines: RoutePolylineBuilder.buildFlowingGradientPolylines(
            filteredPoints,
          ),
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: routePoints.first,
              width: 24,
              height: 24,
              child: const Icon(Icons.trip_origin, color: Colors.green),
            ),
            Marker(
              point: routePoints.last,
              width: 24,
              height: 24,
              child: const Icon(Icons.flag, color: Colors.red),
            ),
          ],
        ),
      ],
    );
  }
}
