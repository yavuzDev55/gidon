import 'package:isar/isar.dart';

part 'planned_route.g.dart';

@embedded
class PlannedWaypointEmbed {
  late String waypointId;
  late double latitude;
  late double longitude;
  String label = '';
}

/// A locally saved planned bike route. Completion of stops is not
/// stored — loading a route always starts from the first stop.
@collection
class PlannedRoute {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String routeId;

  late String name;
  late DateTime createdAt;
  late DateTime updatedAt;
  double distanceMeters = 0;
  List<PlannedWaypointEmbed> waypoints = [];
  List<double> polylineLatitudes = [];
  List<double> polylineLongitudes = [];
}
