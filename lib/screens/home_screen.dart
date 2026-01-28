import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/artwork.dart';
import '../providers/featured_art_provider.dart';
import 'artwork_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Art at GVSU'),
      ),
      body: Consumer<FeaturedArtProvider>(
        builder: (context, provider, child) {
          switch (provider.status) {
            case FeaturedArtStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case FeaturedArtStatus.error:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${provider.errorMessage}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: provider.refresh,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            case FeaturedArtStatus.loaded:
              return _buildContent(context, provider.artworks);
          }
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<Artwork> artworks) {
    if (artworks.isEmpty) {
      return const Center(child: Text('No featured artworks'));
    }

    final heroArtwork = artworks[Random().nextInt(artworks.length)];

    return RefreshIndicator(
      onRefresh: () => context.read<FeaturedArtProvider>().refresh(),
      child: ListView(
        children: [
          _buildHeroImage(context, heroArtwork),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Featured Art',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...artworks.map((artwork) => _buildArtworkCard(context, artwork)),
        ],
      ),
    );
  }

  Widget _buildHeroImage(BuildContext context, Artwork artwork) {
    return GestureDetector(
      onTap: () => _navigateToDetail(context, artwork),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: CachedNetworkImage(
          imageUrl: artwork.mediaLarge ?? artwork.mediaMedium ?? '',
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[300],
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[300],
            child: const Icon(Icons.image_not_supported),
          ),
        ),
      ),
    );
  }

  Widget _buildArtworkCard(BuildContext context, Artwork artwork) {
    return ListTile(
      leading: SizedBox(
        width: 56,
        height: 56,
        child: CachedNetworkImage(
          imageUrl: artwork.thumbnail ?? artwork.mediaSmall ?? '',
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(color: Colors.grey[300]),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[300],
            child: const Icon(Icons.image_not_supported, size: 24),
          ),
        ),
      ),
      title: Text(
        artwork.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: artwork.artistName != null
          ? Text(
              artwork.artistName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      onTap: () => _navigateToDetail(context, artwork),
    );
  }

  void _navigateToDetail(BuildContext context, Artwork artwork) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArtworkDetailScreen(artworkId: artwork.id),
      ),
    );
  }
}
