import 'package:flutter/foundation.dart';
import '../models/artwork.dart';
import '../services/art_gallery_client.dart';

enum ArtworkDetailStatus { loading, loaded, error }

class ArtworkDetailProvider extends ChangeNotifier {
  final ArtGalleryClient _client;
  final int artworkId;

  ArtworkDetailStatus _status = ArtworkDetailStatus.loading;
  Artwork? _artwork;
  String? _errorMessage;

  ArtworkDetailProvider({
    required this.artworkId,
    ArtGalleryClient? client,
  }) : _client = client ?? ArtGalleryClient() {
    _loadArtworkDetail();
  }

  ArtworkDetailStatus get status => _status;
  Artwork? get artwork => _artwork;
  String? get errorMessage => _errorMessage;

  Future<void> _loadArtworkDetail() async {
    try {
      _status = ArtworkDetailStatus.loading;
      notifyListeners();

      _artwork = await _client.fetchArtworkDetail(artworkId);
      _status = ArtworkDetailStatus.loaded;
    } catch (e) {
      _status = ArtworkDetailStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> refresh() async {
    await _loadArtworkDetail();
  }
}
