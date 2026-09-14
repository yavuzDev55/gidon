import 'package:isar/isar.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import '../routing/planned_route.dart';
import '../routing/route_waypoint.dart';
import '../scoring/user_profile.dart';
import 'gps_point.dart';
import 'ride_meta.dart';
import 'ride_stats_calculator.dart';

/// A lightweight summary of a ride, used for displaying ride history
/// without loading every single GPS point into memory.

enum RideSortOption { mostRecent, distance, averageSpeed, duration }

class RideOverview {
  final String rideId;
  final DateTime startTime;
  final int pointCount;
  final String? name;
  final double totalDistanceMeters;
  final double averageSpeedKmh;
  final Duration duration;

  const RideOverview({
    required this.rideId,
    required this.startTime,
    required this.pointCount,
    required this.totalDistanceMeters,
    required this.averageSpeedKmh,
    required this.duration,
    this.name,
  });
}

/// Manages the Isar database instance used across the app.
class IsarService {
  late final Isar isar;

  Future<void> initialize() async {
    final directory = await getApplicationDocumentsDirectory();
    isar = await Isar.open([
      GpsPointSchema,
      UserProfileSchema,
      RideMetaSchema,
      PlannedRouteSchema,
    ], directory: directory.path);
  }

  Future<void> saveGpsPoint(GpsPoint point) async {
    await isar.writeTxn(() async {
      await isar.gpsPoints.put(point);
    });
  }

  Future<List<GpsPoint>> getPointsForRide(String rideId) async {
    return isar.gpsPoints
        .filter()
        .rideIdEqualTo(rideId)
        .sortByTimestamp()
        .findAll();
  }

  Future<void> deletePointsForRide(String rideId) async {
    await isar.writeTxn(() async {
      await isar.gpsPoints.filter().rideIdEqualTo(rideId).deleteAll();
    });
  }

  Future<void> saveRideMeta(
    String rideId, {
    required String name,
    String description = '',
  }) async {
    await isar.writeTxn(() async {
      final existing = await isar.rideMetas
          .filter()
          .rideIdEqualTo(rideId)
          .findFirst();

      final meta = (existing ?? RideMeta())
        ..rideId = rideId
        ..name = name
        ..description = description;

      await isar.rideMetas.put(meta);
    });
  }

  Future<RideMeta?> getRideMeta(String rideId) async {
    return isar.rideMetas.filter().rideIdEqualTo(rideId).findFirst();
  }

  Future<void> deleteRideMeta(String rideId) async {
    await isar.writeTxn(() async {
      await isar.rideMetas.filter().rideIdEqualTo(rideId).deleteAll();
    });
  }

  Future<List<RideOverview>> getAllRideOverviews({
    RideSortOption sortBy = RideSortOption.mostRecent,
  }) async {
    final allPoints = await isar.gpsPoints.where().findAll();

    final Map<String, List<GpsPoint>> groupedByRide = {};
    for (final point in allPoints) {
      groupedByRide.putIfAbsent(point.rideId, () => []).add(point);
    }

    final overviewsWithNulls = await Future.wait(
      groupedByRide.entries.map((entry) async {
        final meta = await getRideMeta(entry.key);
        // A ride only "counts" once it has been explicitly saved
        // (i.e. has a RideMeta record) — an in-progress ride's points
        // are already being written to the DB (Black Box behavior),
        // but shouldn't show up anywhere until the user saves it.
        if (meta == null) return null;

        final points = entry.value
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
        final summary = RideSummary.fromPoints(points);

        return RideOverview(
          rideId: entry.key,
          startTime: points.first.timestamp,
          pointCount: points.length,
          name: meta.name,
          totalDistanceMeters: summary.totalDistanceMeters,
          averageSpeedKmh: summary.averageSpeedKmh,
          duration: summary.duration,
        );
      }),
    );

    final overviews = overviewsWithNulls.whereType<RideOverview>().toList();

    switch (sortBy) {
      case RideSortOption.mostRecent:
        overviews.sort((a, b) => b.startTime.compareTo(a.startTime));
      case RideSortOption.distance:
        overviews.sort(
          (a, b) => b.totalDistanceMeters.compareTo(a.totalDistanceMeters),
        );
      case RideSortOption.averageSpeed:
        overviews.sort(
          (a, b) => b.averageSpeedKmh.compareTo(a.averageSpeedKmh),
        );
      case RideSortOption.duration:
        overviews.sort((a, b) => b.duration.compareTo(a.duration));
    }

    return overviews;
  }

  Future<String> savePlannedRoute({
    String? routeId,
    required String name,
    required List<RouteWaypoint> waypoints,
    required List<LatLng> polyline,
    required double distanceMeters,
  }) async {
    final id = routeId ?? DateTime.now().toUtc().toIso8601String();
    final now = DateTime.now().toUtc();

    await isar.writeTxn(() async {
      final existing = await isar.plannedRoutes
          .filter()
          .routeIdEqualTo(id)
          .findFirst();

      final record = existing ?? PlannedRoute();
      record.routeId = id;
      record.createdAt = existing?.createdAt ?? now;
      record.name = name;
      record.updatedAt = now;
      record.distanceMeters = distanceMeters;
      record.waypoints = waypoints.map((waypoint) {
        return PlannedWaypointEmbed()
          ..waypointId = waypoint.id
          ..latitude = waypoint.latitude
          ..longitude = waypoint.longitude
          ..label = waypoint.label;
      }).toList();
      record.polylineLatitudes = polyline
          .map((point) => point.latitude)
          .toList();
      record.polylineLongitudes = polyline
          .map((point) => point.longitude)
          .toList();

      await isar.plannedRoutes.put(record);
    });

    return id;
  }

  Future<List<PlannedRoute>> getAllPlannedRoutes() async {
    final routes = await isar.plannedRoutes.where().findAll();
    routes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return routes;
  }

  Future<void> deletePlannedRoute(String routeId) async {
    await isar.writeTxn(() async {
      await isar.plannedRoutes.filter().routeIdEqualTo(routeId).deleteAll();
    });
  }
}
