import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class GeocodingResult {
  final String displayName;
  final LatLng position;

  const GeocodingResult({required this.displayName, required this.position});
}

/// Looks up place names using OpenStreetMap's free Nominatim geocoding
/// service. No API key required — only called when the user explicitly
/// submits a search, so usage stays light.
class GeocodingService {
  static const _baseUrl = 'https://nominatim.openstreetmap.org/search';

  static Future<List<GeocodingResult>> search(String query) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.parse(
      _baseUrl,
    ).replace(queryParameters: {'format': 'json', 'q': query, 'limit': '5'});

    final response = await http.get(
      uri,
      headers: {'User-Agent': 'com.gidon.app'},
    );

    if (response.statusCode != 200) return [];

    final List<dynamic> data = jsonDecode(response.body);
    return data.map((item) {
      return GeocodingResult(
        displayName: item['display_name'] as String,
        position: LatLng(
          double.parse(item['lat'] as String),
          double.parse(item['lon'] as String),
        ),
      );
    }).toList();
  }
}
