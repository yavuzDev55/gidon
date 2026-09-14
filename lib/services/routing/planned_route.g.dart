// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'planned_route.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPlannedRouteCollection on Isar {
  IsarCollection<PlannedRoute> get plannedRoutes => this.collection();
}

const PlannedRouteSchema = CollectionSchema(
  name: r'PlannedRoute',
  id: -5893522170653211448,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'distanceMeters': PropertySchema(
      id: 1,
      name: r'distanceMeters',
      type: IsarType.double,
    ),
    r'name': PropertySchema(
      id: 2,
      name: r'name',
      type: IsarType.string,
    ),
    r'polylineLatitudes': PropertySchema(
      id: 3,
      name: r'polylineLatitudes',
      type: IsarType.doubleList,
    ),
    r'polylineLongitudes': PropertySchema(
      id: 4,
      name: r'polylineLongitudes',
      type: IsarType.doubleList,
    ),
    r'routeId': PropertySchema(
      id: 5,
      name: r'routeId',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 6,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'waypoints': PropertySchema(
      id: 7,
      name: r'waypoints',
      type: IsarType.objectList,
      target: r'PlannedWaypointEmbed',
    )
  },
  estimateSize: _plannedRouteEstimateSize,
  serialize: _plannedRouteSerialize,
  deserialize: _plannedRouteDeserialize,
  deserializeProp: _plannedRouteDeserializeProp,
  idName: r'id',
  indexes: {
    r'routeId': IndexSchema(
      id: 3544562048266535092,
      name: r'routeId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'routeId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {r'PlannedWaypointEmbed': PlannedWaypointEmbedSchema},
  getId: _plannedRouteGetId,
  getLinks: _plannedRouteGetLinks,
  attach: _plannedRouteAttach,
  version: '3.1.0+1',
);

int _plannedRouteEstimateSize(
  PlannedRoute object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.polylineLatitudes.length * 8;
  bytesCount += 3 + object.polylineLongitudes.length * 8;
  bytesCount += 3 + object.routeId.length * 3;
  bytesCount += 3 + object.waypoints.length * 3;
  {
    final offsets = allOffsets[PlannedWaypointEmbed]!;
    for (var i = 0; i < object.waypoints.length; i++) {
      final value = object.waypoints[i];
      bytesCount +=
          PlannedWaypointEmbedSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  return bytesCount;
}

void _plannedRouteSerialize(
  PlannedRoute object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeDouble(offsets[1], object.distanceMeters);
  writer.writeString(offsets[2], object.name);
  writer.writeDoubleList(offsets[3], object.polylineLatitudes);
  writer.writeDoubleList(offsets[4], object.polylineLongitudes);
  writer.writeString(offsets[5], object.routeId);
  writer.writeDateTime(offsets[6], object.updatedAt);
  writer.writeObjectList<PlannedWaypointEmbed>(
    offsets[7],
    allOffsets,
    PlannedWaypointEmbedSchema.serialize,
    object.waypoints,
  );
}

PlannedRoute _plannedRouteDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PlannedRoute();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.distanceMeters = reader.readDouble(offsets[1]);
  object.id = id;
  object.name = reader.readString(offsets[2]);
  object.polylineLatitudes = reader.readDoubleList(offsets[3]) ?? [];
  object.polylineLongitudes = reader.readDoubleList(offsets[4]) ?? [];
  object.routeId = reader.readString(offsets[5]);
  object.updatedAt = reader.readDateTime(offsets[6]);
  object.waypoints = reader.readObjectList<PlannedWaypointEmbed>(
        offsets[7],
        PlannedWaypointEmbedSchema.deserialize,
        allOffsets,
        PlannedWaypointEmbed(),
      ) ??
      [];
  return object;
}

P _plannedRouteDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDoubleList(offset) ?? []) as P;
    case 4:
      return (reader.readDoubleList(offset) ?? []) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    case 7:
      return (reader.readObjectList<PlannedWaypointEmbed>(
            offset,
            PlannedWaypointEmbedSchema.deserialize,
            allOffsets,
            PlannedWaypointEmbed(),
          ) ??
          []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _plannedRouteGetId(PlannedRoute object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _plannedRouteGetLinks(PlannedRoute object) {
  return [];
}

void _plannedRouteAttach(
    IsarCollection<dynamic> col, Id id, PlannedRoute object) {
  object.id = id;
}

extension PlannedRouteByIndex on IsarCollection<PlannedRoute> {
  Future<PlannedRoute?> getByRouteId(String routeId) {
    return getByIndex(r'routeId', [routeId]);
  }

  PlannedRoute? getByRouteIdSync(String routeId) {
    return getByIndexSync(r'routeId', [routeId]);
  }

  Future<bool> deleteByRouteId(String routeId) {
    return deleteByIndex(r'routeId', [routeId]);
  }

  bool deleteByRouteIdSync(String routeId) {
    return deleteByIndexSync(r'routeId', [routeId]);
  }

  Future<List<PlannedRoute?>> getAllByRouteId(List<String> routeIdValues) {
    final values = routeIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'routeId', values);
  }

  List<PlannedRoute?> getAllByRouteIdSync(List<String> routeIdValues) {
    final values = routeIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'routeId', values);
  }

  Future<int> deleteAllByRouteId(List<String> routeIdValues) {
    final values = routeIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'routeId', values);
  }

  int deleteAllByRouteIdSync(List<String> routeIdValues) {
    final values = routeIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'routeId', values);
  }

  Future<Id> putByRouteId(PlannedRoute object) {
    return putByIndex(r'routeId', object);
  }

  Id putByRouteIdSync(PlannedRoute object, {bool saveLinks = true}) {
    return putByIndexSync(r'routeId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByRouteId(List<PlannedRoute> objects) {
    return putAllByIndex(r'routeId', objects);
  }

  List<Id> putAllByRouteIdSync(List<PlannedRoute> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'routeId', objects, saveLinks: saveLinks);
  }
}

extension PlannedRouteQueryWhereSort
    on QueryBuilder<PlannedRoute, PlannedRoute, QWhere> {
  QueryBuilder<PlannedRoute, PlannedRoute, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PlannedRouteQueryWhere
    on QueryBuilder<PlannedRoute, PlannedRoute, QWhereClause> {
  QueryBuilder<PlannedRoute, PlannedRoute, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterWhereClause> routeIdEqualTo(
      String routeId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'routeId',
        value: [routeId],
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterWhereClause> routeIdNotEqualTo(
      String routeId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'routeId',
              lower: [],
              upper: [routeId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'routeId',
              lower: [routeId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'routeId',
              lower: [routeId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'routeId',
              lower: [],
              upper: [routeId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension PlannedRouteQueryFilter
    on QueryBuilder<PlannedRoute, PlannedRoute, QFilterCondition> {
  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      distanceMetersEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'distanceMeters',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      distanceMetersGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'distanceMeters',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      distanceMetersLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'distanceMeters',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      distanceMetersBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'distanceMeters',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      polylineLatitudesElementEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'polylineLatitudes',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      polylineLatitudesElementGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'polylineLatitudes',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      polylineLatitudesElementLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'polylineLatitudes',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      polylineLatitudesElementBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'polylineLatitudes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      polylineLatitudesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'polylineLatitudes',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      polylineLatitudesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'polylineLatitudes',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      polylineLatitudesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'polylineLatitudes',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      polylineLatitudesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'polylineLatitudes',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      polylineLatitudesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'polylineLatitudes',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      polylineLatitudesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'polylineLatitudes',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      polylineLongitudesElementEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'polylineLongitudes',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      polylineLongitudesElementGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'polylineLongitudes',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      polylineLongitudesElementLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'polylineLongitudes',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      polylineLongitudesElementBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'polylineLongitudes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      polylineLongitudesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'polylineLongitudes',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      polylineLongitudesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'polylineLongitudes',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      polylineLongitudesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'polylineLongitudes',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      polylineLongitudesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'polylineLongitudes',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      polylineLongitudesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'polylineLongitudes',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      polylineLongitudesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'polylineLongitudes',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      routeIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'routeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      routeIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'routeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      routeIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'routeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      routeIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'routeId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      routeIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'routeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      routeIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'routeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      routeIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'routeId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      routeIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'routeId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      routeIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'routeId',
        value: '',
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      routeIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'routeId',
        value: '',
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      waypointsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'waypoints',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      waypointsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'waypoints',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      waypointsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'waypoints',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      waypointsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'waypoints',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      waypointsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'waypoints',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      waypointsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'waypoints',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension PlannedRouteQueryObject
    on QueryBuilder<PlannedRoute, PlannedRoute, QFilterCondition> {
  QueryBuilder<PlannedRoute, PlannedRoute, QAfterFilterCondition>
      waypointsElement(FilterQuery<PlannedWaypointEmbed> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'waypoints');
    });
  }
}

extension PlannedRouteQueryLinks
    on QueryBuilder<PlannedRoute, PlannedRoute, QFilterCondition> {}

extension PlannedRouteQuerySortBy
    on QueryBuilder<PlannedRoute, PlannedRoute, QSortBy> {
  QueryBuilder<PlannedRoute, PlannedRoute, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterSortBy>
      sortByDistanceMeters() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distanceMeters', Sort.asc);
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterSortBy>
      sortByDistanceMetersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distanceMeters', Sort.desc);
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterSortBy> sortByRouteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routeId', Sort.asc);
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterSortBy> sortByRouteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routeId', Sort.desc);
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension PlannedRouteQuerySortThenBy
    on QueryBuilder<PlannedRoute, PlannedRoute, QSortThenBy> {
  QueryBuilder<PlannedRoute, PlannedRoute, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterSortBy>
      thenByDistanceMeters() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distanceMeters', Sort.asc);
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterSortBy>
      thenByDistanceMetersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distanceMeters', Sort.desc);
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterSortBy> thenByRouteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routeId', Sort.asc);
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterSortBy> thenByRouteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'routeId', Sort.desc);
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension PlannedRouteQueryWhereDistinct
    on QueryBuilder<PlannedRoute, PlannedRoute, QDistinct> {
  QueryBuilder<PlannedRoute, PlannedRoute, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QDistinct>
      distinctByDistanceMeters() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'distanceMeters');
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QDistinct>
      distinctByPolylineLatitudes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'polylineLatitudes');
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QDistinct>
      distinctByPolylineLongitudes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'polylineLongitudes');
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QDistinct> distinctByRouteId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'routeId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlannedRoute, PlannedRoute, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension PlannedRouteQueryProperty
    on QueryBuilder<PlannedRoute, PlannedRoute, QQueryProperty> {
  QueryBuilder<PlannedRoute, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PlannedRoute, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<PlannedRoute, double, QQueryOperations>
      distanceMetersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'distanceMeters');
    });
  }

  QueryBuilder<PlannedRoute, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<PlannedRoute, List<double>, QQueryOperations>
      polylineLatitudesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'polylineLatitudes');
    });
  }

  QueryBuilder<PlannedRoute, List<double>, QQueryOperations>
      polylineLongitudesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'polylineLongitudes');
    });
  }

  QueryBuilder<PlannedRoute, String, QQueryOperations> routeIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'routeId');
    });
  }

  QueryBuilder<PlannedRoute, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<PlannedRoute, List<PlannedWaypointEmbed>, QQueryOperations>
      waypointsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'waypoints');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const PlannedWaypointEmbedSchema = Schema(
  name: r'PlannedWaypointEmbed',
  id: -6401839894078505082,
  properties: {
    r'label': PropertySchema(
      id: 0,
      name: r'label',
      type: IsarType.string,
    ),
    r'latitude': PropertySchema(
      id: 1,
      name: r'latitude',
      type: IsarType.double,
    ),
    r'longitude': PropertySchema(
      id: 2,
      name: r'longitude',
      type: IsarType.double,
    ),
    r'waypointId': PropertySchema(
      id: 3,
      name: r'waypointId',
      type: IsarType.string,
    )
  },
  estimateSize: _plannedWaypointEmbedEstimateSize,
  serialize: _plannedWaypointEmbedSerialize,
  deserialize: _plannedWaypointEmbedDeserialize,
  deserializeProp: _plannedWaypointEmbedDeserializeProp,
);

int _plannedWaypointEmbedEstimateSize(
  PlannedWaypointEmbed object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.label.length * 3;
  bytesCount += 3 + object.waypointId.length * 3;
  return bytesCount;
}

void _plannedWaypointEmbedSerialize(
  PlannedWaypointEmbed object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.label);
  writer.writeDouble(offsets[1], object.latitude);
  writer.writeDouble(offsets[2], object.longitude);
  writer.writeString(offsets[3], object.waypointId);
}

PlannedWaypointEmbed _plannedWaypointEmbedDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PlannedWaypointEmbed();
  object.label = reader.readString(offsets[0]);
  object.latitude = reader.readDouble(offsets[1]);
  object.longitude = reader.readDouble(offsets[2]);
  object.waypointId = reader.readString(offsets[3]);
  return object;
}

P _plannedWaypointEmbedDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension PlannedWaypointEmbedQueryFilter on QueryBuilder<PlannedWaypointEmbed,
    PlannedWaypointEmbed, QFilterCondition> {
  QueryBuilder<PlannedWaypointEmbed, PlannedWaypointEmbed,
      QAfterFilterCondition> labelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedWaypointEmbed, PlannedWaypointEmbed,
      QAfterFilterCondition> labelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedWaypointEmbed, PlannedWaypointEmbed,
      QAfterFilterCondition> labelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedWaypointEmbed, PlannedWaypointEmbed,
      QAfterFilterCondition> labelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'label',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedWaypointEmbed, PlannedWaypointEmbed,
      QAfterFilterCondition> labelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedWaypointEmbed, PlannedWaypointEmbed,
      QAfterFilterCondition> labelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedWaypointEmbed, PlannedWaypointEmbed,
          QAfterFilterCondition>
      labelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'label',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedWaypointEmbed, PlannedWaypointEmbed,
          QAfterFilterCondition>
      labelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'label',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedWaypointEmbed, PlannedWaypointEmbed,
      QAfterFilterCondition> labelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'label',
        value: '',
      ));
    });
  }

  QueryBuilder<PlannedWaypointEmbed, PlannedWaypointEmbed,
      QAfterFilterCondition> labelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'label',
        value: '',
      ));
    });
  }

  QueryBuilder<PlannedWaypointEmbed, PlannedWaypointEmbed,
      QAfterFilterCondition> latitudeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedWaypointEmbed, PlannedWaypointEmbed,
      QAfterFilterCondition> latitudeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedWaypointEmbed, PlannedWaypointEmbed,
      QAfterFilterCondition> latitudeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedWaypointEmbed, PlannedWaypointEmbed,
      QAfterFilterCondition> latitudeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'latitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedWaypointEmbed, PlannedWaypointEmbed,
      QAfterFilterCondition> longitudeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedWaypointEmbed, PlannedWaypointEmbed,
      QAfterFilterCondition> longitudeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedWaypointEmbed, PlannedWaypointEmbed,
      QAfterFilterCondition> longitudeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedWaypointEmbed, PlannedWaypointEmbed,
      QAfterFilterCondition> longitudeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'longitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedWaypointEmbed, PlannedWaypointEmbed,
      QAfterFilterCondition> waypointIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'waypointId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedWaypointEmbed, PlannedWaypointEmbed,
      QAfterFilterCondition> waypointIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'waypointId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedWaypointEmbed, PlannedWaypointEmbed,
      QAfterFilterCondition> waypointIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'waypointId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedWaypointEmbed, PlannedWaypointEmbed,
      QAfterFilterCondition> waypointIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'waypointId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedWaypointEmbed, PlannedWaypointEmbed,
      QAfterFilterCondition> waypointIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'waypointId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedWaypointEmbed, PlannedWaypointEmbed,
      QAfterFilterCondition> waypointIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'waypointId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedWaypointEmbed, PlannedWaypointEmbed,
          QAfterFilterCondition>
      waypointIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'waypointId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedWaypointEmbed, PlannedWaypointEmbed,
          QAfterFilterCondition>
      waypointIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'waypointId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedWaypointEmbed, PlannedWaypointEmbed,
      QAfterFilterCondition> waypointIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'waypointId',
        value: '',
      ));
    });
  }

  QueryBuilder<PlannedWaypointEmbed, PlannedWaypointEmbed,
      QAfterFilterCondition> waypointIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'waypointId',
        value: '',
      ));
    });
  }
}

extension PlannedWaypointEmbedQueryObject on QueryBuilder<PlannedWaypointEmbed,
    PlannedWaypointEmbed, QFilterCondition> {}
