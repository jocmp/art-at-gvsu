import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/artwork.dart';

class ArtGalleryClient {
  static const _baseUrl = Config.apiBaseUrl;

  final http.Client _client;

  ArtGalleryClient({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Artwork>> fetchFeaturedArt() async {
    final url = Uri.parse('$_baseUrl/objectSearch?q=featured_art');
    final response = await _client.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch featured art: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (json['ok'] != true) {
      throw Exception('API returned error');
    }

    final artworks = <Artwork>[];
    for (final entry in json.entries) {
      if (entry.key == 'ok') continue;
      if (entry.value is Map<String, dynamic>) {
        final artwork = Artwork.fromJson(entry.value);
        if (artwork.isPublic) {
          artworks.add(artwork);
        }
      }
    }

    return artworks;
  }

  Future<Artwork> fetchArtworkDetail(int id) async {
    final url = Uri.parse('$_baseUrl/objectDetail?id=$id');
    final response = await _client.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch artwork detail: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (json['ok'] != true) {
      throw Exception('API returned error');
    }

    return Artwork.fromJson(json);
  }
}
