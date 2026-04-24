class VideoModel {
  final String? id;
  final String? adminId;
  final String title;
  final String description;
  final String category;
  final String videoUrl;
  final String? thumbnailUrl;
  final String duration;
  final DateTime createdAt;

  // --- NEW FIELDS ---
  final List<String> tags;
  final bool isSensitive;

  VideoModel({
    this.id,
    this.adminId,
    required this.title,
    required this.description,
    required this.category,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.duration,
    required this.createdAt,
    // --- Initialize New Fields ---
    this.tags = const [],
    this.isSensitive = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'adminId': adminId,
      'title': title,
      'description': description,
      'category': category,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration,
      'createdAt': createdAt.toIso8601String(),
      // --- Serialize New Fields ---
      'tags': tags,
      'isSensitive': isSensitive,
    };
  }

  factory VideoModel.fromMap(String id, Map<String, dynamic> map) {
    return VideoModel(
      id: id,
      adminId: map['adminId'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'General',
      videoUrl: map['videoUrl'] ?? '',
      thumbnailUrl: map['thumbnailUrl'],
      duration: map['duration'] ?? '00:00',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      // --- Deserialize New Fields ---
      tags: List<String>.from(map['tags'] ?? []),
      isSensitive: map['isSensitive'] ?? false,
    );
  }

  VideoModel copyWith({
    String? id,
    String? adminId,
    String? title,
    String? description,
    String? category,
    String? videoUrl,
    String? thumbnailUrl,
    String? duration,
    DateTime? createdAt,
    // --- New Fields in CopyWith ---
    List<String>? tags,
    bool? isSensitive,
  }) {
    return VideoModel(
      id: id ?? this.id,
      adminId: adminId ?? this.adminId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      // --- Assign New Fields ---
      tags: tags ?? this.tags,
      isSensitive: isSensitive ?? this.isSensitive,
    );
  }
}