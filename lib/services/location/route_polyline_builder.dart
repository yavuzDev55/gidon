import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../theme/app_colors.dart';
import 'gps_point.dart';
import 'ride_stats_calculator.dart';

/// Builds the route line as many small colored segments instead of
/// one solid Polyline. Color flows smoothly between blue and green
/// using a sine wave over distance — no abrupt resets, just a
/// continuous back-and-forth pulse roughly once per kilometer. Gives
/// a sense of direction/flow and helps distinguish overlapping
/// passes over the same street.
class RoutePolylineBuilder {
  // A full blue->green->blue cycle spans this many meters. Using a
  // sine wave means there's no sudden jump anywhere along the route,
  // unlike a sawtooth/modulo reset.
  static const double _cycleMeters = 2000;

  static List<Polyline> buildFlowingGradientPolylines(
    List<GpsPoint> points, {
    double strokeWidth = 4,
  }) {
    if (points.length < 2) return [];

    final segments = <Polyline>[];
    double cumulativeMeters = 0;

    for (int i = 1; i < points.length; i++) {
      final a = points[i - 1];
      final b = points[i];
      final segmentDistance = RideStatsCalculator.distanceBetweenMeters(a, b);

      final midDistance = cumulativeMeters + segmentDistance / 2;
      final angle = (midDistance / _cycleMeters) * 2 * pi;
      // sin() oscillates smoothly between -1 and 1 with no
      // discontinuities anywhere — remapped here to 0..1.
      final fraction = (sin(angle) + 1) / 2;

      final color = Color.lerp(
        AppColors.routeTrailBlue,
        AppColors.routeTrailGreen,
        fraction,
      )!;

      segments.add(
        Polyline(
          points: [
            LatLng(a.latitude, a.longitude),
            LatLng(b.latitude, b.longitude),
          ],
          strokeWidth: strokeWidth,
          color: color,
        ),
      );

      cumulativeMeters += segmentDistance;
    }

    return segments;
  }
}
