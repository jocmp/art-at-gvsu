import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/artwork.dart';
import '../providers/artwork_detail_provider.dart';

class ArtworkDetailScreen extends StatelessWidget {
  final int artworkId;

  const ArtworkDetailScreen({super.key, required this.artworkId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ArtworkDetailProvider(artworkId: artworkId),
      child: Scaffold(
        appBar: AppBar(),
        body: Consumer<ArtworkDetailProvider>(
          builder: (context, provider, child) {
            switch (provider.status) {
              case ArtworkDetailStatus.loading:
                return const Center(child: CircularProgressIndicator());
              case ArtworkDetailStatus.error:
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
              case ArtworkDetailStatus.loaded:
                return _buildContent(context, provider.artwork!);
            }
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Artwork artwork) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageCarousel(artwork),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artwork.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (artwork.artistName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    artwork.artistName!,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                ..._buildDetailFields(artwork),
                if (artwork.relatedWorks.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildRelatedWorks(context, artwork.relatedWorks),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(Artwork artwork) {
    final images = artwork.mediaRepresentations.isNotEmpty
        ? artwork.mediaRepresentations
        : [artwork.mediaLarge ?? artwork.mediaMedium ?? ''];

    final validImages = images.where((url) => url.isNotEmpty).toList();

    if (validImages.isEmpty) {
      return AspectRatio(
        aspectRatio: 1,
        child: Container(
          color: Colors.grey[300],
          child: const Icon(Icons.image_not_supported, size: 64),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 1,
      child: PageView.builder(
        itemCount: validImages.length,
        itemBuilder: (context, index) {
          return CachedNetworkImage(
            imageUrl: validImages[index],
            fit: BoxFit.contain,
            placeholder: (context, url) => Container(
              color: Colors.grey[300],
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[300],
              child: const Icon(Icons.image_not_supported, size: 64),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildDetailFields(Artwork artwork) {
    final fields = <Widget>[];

    void addField(String label, String? value) {
      if (value != null && value.isNotEmpty) {
        fields.add(_buildDetailField(label, value));
      }
    }

    addField('Description', artwork.workDescription);
    addField('Historical Context', artwork.historicalContext);
    addField('Medium', artwork.workMedium);
    addField('Date', artwork.workDate);
    addField('Identifier', artwork.identifier);
    addField('Credit Line', artwork.creditLine);
    addField('Location', artwork.location);

    return fields;
  }

  Widget _buildDetailField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedWorks(BuildContext context, List<Artwork> relatedWorks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Related Works',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: relatedWorks.length,
            itemBuilder: (context, index) {
              final work = relatedWorks[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ArtworkDetailScreen(artworkId: work.id),
                    ),
                  );
                },
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: CachedNetworkImage(
                          imageUrl: work.thumbnail ?? work.mediaMedium ?? '',
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(color: Colors.grey[300]),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        work.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
