import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import 'package:gidon/services/routing/bike_routing_service.dart';
import 'package:gidon/services/routing/route_plan_logic.dart';
import 'package:gidon/services/routing/route_waypoint.dart';

RouteWaypoint _stop(
  String id,
  double lat,
  double lng, {
  bool completed = false,
}) {
  return RouteWaypoint(
    id: id,
    latitude: lat,
    longitude: lng,
    completed: completed,
  );
}

void main() {
  group('RoutePlanLogic', () {
    test('nextIncompleteIndex skips completed stops', () {
      final waypoints = [
        _stop('a', 41.0, 29.0, completed: true),
        _stop('b', 41.1, 29.1),
        _stop('c', 41.2, 29.2),
      ];

      expect(RoutePlanLogic.nextIncompleteIndex(waypoints), 1);
    });

    test('completeIfArrived only completes the next stop', () {
      final next = _stop('b', 41.037, 28.985);
      final later = _stop('c', 41.037, 28.985);
      final waypoints = [
        _stop('a', 41.0, 29.0, completed: true),
        next,
        later,
      ];

      final updated = RoutePlanLogic.completeIfArrived(
        waypoints: waypoints,
        position: next.position,
      );

      expect(updated[1].completed, isTrue);
      expect(updated[2].completed, isFalse);
    });

    test('completeIfArrived ignores a distant next stop', () {
      final waypoints = [_stop('a', 41.0, 29.0)];
      final updated = RoutePlanLogic.completeIfArrived(
        waypoints: waypoints,
        position: const LatLng(41.2, 29.2),
      );

      expect(updated[0].completed, isFalse);
      expect(identical(updated, waypoints), isTrue);
    });

    test('reorder matches ReorderableListView index rules', () {
      final waypoints = [
        _stop('a', 1, 1),
        _stop('b', 2, 2),
        _stop('c', 3, 3),
      ];

      final movedDown = RoutePlanLogic.reorder(waypoints, 0, 2);
      expect(movedDown.map((w) => w.id).toList(), ['b', 'a', 'c']);

      final movedUp = RoutePlanLogic.reorder(waypoints, 2, 0);
      expect(movedUp.map((w) => w.id).toList(), ['c', 'a', 'b']);
    });

    test('routingStops prepends origin and drops completed stops', () {
      final waypoints = [
        _stop('a', 41.0, 29.0, completed: true),
        _stop('b', 41.1, 29.1),
        _stop('c', 41.2, 29.2),
      ];
      const origin = LatLng(40.99, 28.99);

      final stops = RoutePlanLogic.routingStops(
        waypoints: waypoints,
        origin: origin,
      );

      expect(stops, [
        origin,
        const LatLng(41.1, 29.1),
        const LatLng(41.2, 29.2),
      ]);
    });

    test('shouldReroute waits for both distance and interval', () {
      const origin = LatLng(41.0, 29.0);
      const nearby = LatLng(41.00005, 29.0);
      const farther = LatLng(41.001, 29.0);
      final t0 = DateTime.utc(2026, 1, 1, 12, 0, 0);

      expect(
        RoutePlanLogic.shouldReroute(
          current: farther,
          lastRoutedFrom: origin,
          now: t0.add(const Duration(seconds: 2)),
          lastRoutedAt: t0,
        ),
        isFalse,
      );

      expect(
        RoutePlanLogic.shouldReroute(
          current: nearby,
          lastRoutedFrom: origin,
          now: t0.add(const Duration(seconds: 20)),
          lastRoutedAt: t0,
        ),
        isFalse,
      );

      expect(
        RoutePlanLogic.shouldReroute(
          current: farther,
          lastRoutedFrom: origin,
          now: t0.add(const Duration(seconds: 20)),
          lastRoutedAt: t0,
        ),
        isTrue,
      );
    });
  });

  group('BikeRoutingService', () {
    test('parseOsrmResponse reads geojson coordinates', () {
      const body = '''
{
  "code": "Ok",
  "routes": [
    {
      "distance": 1234.5,
      "geometry": {
        "coordinates": [[29.0, 41.0], [29.1, 41.1]]
      }
    }
  ]
}
''';

      final result = BikeRoutingService.parseOsrmResponse(body);
      expect(result.distanceMeters, 1234.5);
      expect(result.points, [
        const LatLng(41.0, 29.0),
        const LatLng(41.1, 29.1),
      ]);
    });

    test('parseOsrmResponse throws when OSRM returns an error code', () {
      expect(
        () => BikeRoutingService.parseOsrmResponse('{"code":"NoRoute"}'),
        throwsA(isA<BikeRoutingException>()),
      );
    });
  });
}
