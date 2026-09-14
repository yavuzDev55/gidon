import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class BikeRoutingResult {
  final List<LatLng> points;
  final double distanceMeters;

  const BikeRoutingResult({
    required this.points,
    required this.distanceMeters,
  });
}

/// Bicycle routing against the public OSM bike OSRM instance.
/// Same ecosystem as the existing Nominatim search — no API key.
class BikeRoutingService {
  static const _baseUrl =
      'https://routing.openstreetmap.de/routed-bike/route/v1/driving';

  final http.Client _client;

  BikeRoutingService({http.Client? client}) : _client = client ?? http.Client();

  Future<BikeRoutingResult> route(List<LatLng> stops) async {
    if (stops.length < 2) {
      return BikeRoutingResult(points: List.of(stops), distanceMeters: 0);
    }

    final coords = stops
        .map((stop) => '${stop.longitude},${stop.latitude}')
        .join(';');
    final uri = Uri.parse('$_baseUrl/$coords').replace(
      queryParameters: {
        'overview': 'full',
        'geometries': 'geojson',
        'alternatives': 'false',
      },
    );

    final response = await _client.get(
      uri,
      headers: {'User-Agent': 'com.gidon.app'},
    );

    if (response.statusCode != 200) {
      throw BikeRoutingException(
        'Routing failed (${response.statusCode}).',
      );
    }

    return parseOsrmResponse(response.body);
  }

  static BikeRoutingResult parseOsrmResponse(String body) {
    final data = jsonDecode(body) as Map<String, dynamic>;
    final code = data['code'] as String?;
    if (code != 'Ok') {
      throw BikeRoutingException(code ?? 'Routing failed.');
    }

    final routes = data['routes'] as List<dynamic>?;
    if (routes == null || routes.isEmpty) {
      throw const BikeRoutingException('No bike route found.');
    }

    final route = routes.first as Map<String, dynamic>;
    final distance = (route['distance'] as num?)?.toDouble() ?? 0;
    final geometry = route['geometry'] as Map<String, dynamic>?;
    final coordinates = geometry?['coordinates'] as List<dynamic>? ?? [];

    final points = coordinates.map((item) {
      final pair = item as List<dynamic>;
      return LatLng((pair[1] as num).toDouble(), (pair[0] as num).toDouble());
    }).toList();

    if (points.length < 2) {
      throw const BikeRoutingException('No bike route found.');
    }

    return BikeRoutingResult(points: points, distanceMeters: distance);
  }
}

class BikeRoutingException implements Exception {
  final String message;

  const BikeRoutingException(this.message);

  @override
  String toString() => message;
}
