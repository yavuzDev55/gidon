import 'package:isar/isar.dart';

part 'ride_meta.g.dart';

/// Stores optional metadata for a ride that isn't part of the raw
/// GPS data — a user-given name and description.
@collection
class RideMeta {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String rideId;

  late String name;
  String description = '';
}
