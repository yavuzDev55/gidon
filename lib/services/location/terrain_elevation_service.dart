import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Looks up terrain elevation (in meters) for GPS coordinates using
/// the free Open-Meteo elevation API. Much more reliable than a
/// phone's raw GPS altitude reading, which has no barometric sensor
/// backing it and drifts significantly (can be off by dozens of
/// meters on consumer phones).
class TerrainElevationService {
  static const _baseUrl = 'https://api.open-meteo.com/v1/elevation';
  static const _chunkSize = 100;

  /// Returns elevation in meters for each point, in the same order.
  /// Returns null if the lookup fails for any reason (offline, rate
  /// limited, timeout, etc.) — callers should fall back to GPS
  /// altitude in that case.
  static Future<List<double>?> fetchElevations(List<LatLng> points) async {
    if (points.isEmpty) return [];

    try {
      final results = <double>[];

      for (var i = 0; i < points.length; i += _chunkSize) {
        final end = (i + _chunkSize).clamp(0, points.length);
        final chunk = points.sublist(i, end);

        final lats = chunk.map((p) => p.latitude.toStringAsFixed(6)).join(',');
        final lons = chunk.map((p) => p.longitude.toStringAsFixed(6)).join(',');

        final uri = Uri.parse(
          _baseUrl,
        ).replace(queryParameters: {'latitude': lats, 'longitude': lons});

        final response = await http
            .get(uri)
            .timeout(const Duration(seconds: 10));
        if (response.statusCode != 200) return null;

        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final elevations = (data['elevation'] as List).cast<num>();
        results.addAll(elevations.map((e) => e.toDouble()));
      }

      return results;
    } catch (_) {
      return null;
    }
  }
}
