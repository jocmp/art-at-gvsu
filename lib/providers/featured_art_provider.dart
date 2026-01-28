import 'package:flutter/foundation.dart';
import '../models/artwork.dart';
import '../services/art_gallery_client.dart';

enum FeaturedArtStatus { loading, loaded, error }

class FeaturedArtProvider extends ChangeNotifier {
  final ArtGalleryClient _client;

  FeaturedArtStatus _status = FeaturedArtStatus.loading;
  List<Artwork> _artworks = [];
  String? _errorMessage;

  FeaturedArtProvider({ArtGalleryClient? client})
      : _client = client ?? ArtGalleryClient() {
    _loadFeaturedArt();
  }

  FeaturedArtStatus get status => _status;
  List<Artwork> get artworks => _artworks;
  String? get errorMessage => _errorMessage;

  Future<void> _loadFeaturedArt() async {
    try {
      _status = FeaturedArtStatus.loading;
      notifyListeners();

      _artworks = await _client.fetchFeaturedArt();
      _status = FeaturedArtStatus.loaded;
    } catch (e) {
      _status = FeaturedArtStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> refresh() async {
    await _loadFeaturedArt();
  }
}
