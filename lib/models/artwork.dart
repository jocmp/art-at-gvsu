class Artwork {
  final int id;
  final String name;
  final int? artistId;
  final String? artistName;
  final String? workDescription;
  final String? historicalContext;
  final String? workMedium;
  final String? workDate;
  final String? location;
  final int? locationId;
  final String? identifier;
  final String? creditLine;
  final String? mediaSmall;
  final String? mediaMedium;
  final String? mediaLarge;
  final String? thumbnail;
  final List<String> mediaRepresentations;
  final List<Artwork> relatedWorks;
  final bool isPublic;

  Artwork({
    required this.id,
    required this.name,
    this.artistId,
    this.artistName,
    this.workDescription,
    this.historicalContext,
    this.workMedium,
    this.workDate,
    this.location,
    this.locationId,
    this.identifier,
    this.creditLine,
    this.mediaSmall,
    this.mediaMedium,
    this.mediaLarge,
    this.thumbnail,
    this.mediaRepresentations = const [],
    this.relatedWorks = const [],
    this.isPublic = true,
  });

  factory Artwork.fromJson(Map<String, dynamic> json) {
    final mediaReps = _parseMediaRepresentations(json['media_reps'] as String?);
    final relatedWorks = _parseRelatedWorks(json['related_objects']);

    return Artwork(
      id: _parseInt(json['object_id']),
      name: json['object_name'] as String? ?? '',
      artistId: _parseIntOrNull(json['entity_id']),
      artistName: json['entity_name'] as String?,
      workDescription: json['work_description'] as String?,
      historicalContext: json['historical_context'] as String?,
      workMedium: json['work_medium'] as String?,
      workDate: json['work_date'] as String?,
      location: json['location'] as String?,
      locationId: _parseIntOrNull(json['location_id']),
      identifier: json['id_number'] as String?,
      creditLine: json['credit_line'] as String?,
      mediaSmall: json['media_small_url'] as String?,
      mediaMedium: json['media_medium_url'] as String?,
      mediaLarge: json['media_large_url'] as String?,
      thumbnail: json['media_thumb_url'] as String?,
      mediaRepresentations: mediaReps,
      relatedWorks: relatedWorks,
      isPublic: json['access'] == '1',
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static int? _parseIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static List<String> _parseMediaRepresentations(String? mediaReps) {
    if (mediaReps == null || mediaReps.isEmpty) return [];
    return mediaReps.split('|').where((url) => url.isNotEmpty).toList();
  }

  static List<Artwork> _parseRelatedWorks(dynamic relatedObjects) {
    if (relatedObjects == null) return [];

    if (relatedObjects is String && relatedObjects.isNotEmpty) {
      final parts = relatedObjects.split(';');
      final works = <Artwork>[];
      for (final part in parts) {
        final fields = part.split('|');
        if (fields.length >= 5) {
          works.add(Artwork(
            id: int.tryParse(fields[0]) ?? 0,
            name: fields[1],
            artistName: fields[2],
            thumbnail: fields[3],
            mediaMedium: fields[4],
          ));
        }
      }
      return works;
    }

    return [];
  }
}
