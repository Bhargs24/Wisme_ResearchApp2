class Journey {
  final String id;
  final String title;
  final String description;
  final String category;
  final List<String> episodeIds;
  final int totalDuration; // in seconds
  final String iconName;
  final String colorHex;
  final bool isActive;
  final Map<String, dynamic> metadata;

  Journey({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.episodeIds,
    required this.totalDuration,
    required this.iconName,
    required this.colorHex,
    this.isActive = true,
    this.metadata = const {},
  });

  factory Journey.fromMap(Map<String, dynamic> map) {
    return Journey(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      episodeIds: List<String>.from(map['episodeIds'] ?? []),
      totalDuration: map['totalDuration'] ?? 0,
      iconName: map['iconName'] ?? 'code',
      colorHex: map['colorHex'] ?? '#2196F3',
      isActive: map['isActive'] ?? true,
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'episodeIds': episodeIds,
      'totalDuration': totalDuration,
      'iconName': iconName,
      'colorHex': colorHex,
      'isActive': isActive,
      'metadata': metadata,
    };
  }
}

class Episode {
  final String id;
  final String journeyId;
  final String title;
  final String description;
  final String audioUrl; // Placeholder URL for now
  final int duration; // in seconds
  final int order;
  final String transcript;
  final List<String> keyPoints;
  final Map<String, dynamic> metadata;

  Episode({
    required this.id,
    required this.journeyId,
    required this.title,
    required this.description,
    required this.audioUrl,
    required this.duration,
    required this.order,
    this.transcript = '',
    this.keyPoints = const [],
    this.metadata = const {},
  });

  factory Episode.fromMap(Map<String, dynamic> map) {
    return Episode(
      id: map['id'] ?? '',
      journeyId: map['journeyId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      audioUrl: map['audioUrl'] ?? '',
      duration: map['duration'] ?? 0,
      order: map['order'] ?? 0,
      transcript: map['transcript'] ?? '',
      keyPoints: List<String>.from(map['keyPoints'] ?? []),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'journeyId': journeyId,
      'title': title,
      'description': description,
      'audioUrl': audioUrl,
      'duration': duration,
      'order': order,
      'transcript': transcript,
      'keyPoints': keyPoints,
      'metadata': metadata,
    };
  }
}
