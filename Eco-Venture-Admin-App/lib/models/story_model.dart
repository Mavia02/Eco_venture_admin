class StoryPage {
  final String text;
  final String imageUrl;

  StoryPage({required this.text, required this.imageUrl});

  Map<String, dynamic> toMap() => {'text': text, 'image': imageUrl};

  factory StoryPage.fromMap(Map<String, dynamic> map) {
    return StoryPage(
      text: map['text'] ?? '',
      imageUrl: map['image'] ?? '',
    );
  }
}

class StoryModel {
  final String? id;
  final String? adminId;
  final String title;
  final String description;
  final String? thumbnailUrl;
  final List<StoryPage> pages;
  final DateTime createdAt;

  // --- NEW FIELDS ---
  final List<String> tags;
  final bool isSensitive;

  StoryModel({
    this.id,
    this.adminId,
    required this.title,
    required this.description,
    this.thumbnailUrl,
    required this.pages,
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
      'thumbnailUrl': thumbnailUrl,
      'pages': pages.map((p) => p.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      // --- Serialize New Fields ---
      'tags': tags,
      'isSensitive': isSensitive,
    };
  }

  factory StoryModel.fromMap(String id, Map<String, dynamic> map) {
    return StoryModel(
      id: id,
      adminId: map['adminId'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      thumbnailUrl: map['thumbnailUrl'],
      pages: List<StoryPage>.from(
          (map['pages'] as List<dynamic>? ?? []).map((x) => StoryPage.fromMap(Map<String, dynamic>.from(x)))
      ),
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      // --- Deserialize New Fields ---
      tags: List<String>.from(map['tags'] ?? []),
      isSensitive: map['isSensitive'] ?? false,
    );
  }

  StoryModel copyWith({
    String? id,
    String? adminId,
    String? title,
    String? description,
    String? thumbnailUrl,
    List<StoryPage>? pages,
    DateTime? createdAt,
    // --- New Fields in CopyWith ---
    List<String>? tags,
    bool? isSensitive,
  }) {
    return StoryModel(
      id: id ?? this.id,
      adminId: adminId ?? this.adminId,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      pages: pages ?? this.pages,
      createdAt: createdAt ?? this.createdAt,
      // --- Assign New Fields ---
      tags: tags ?? this.tags,
      isSensitive: isSensitive ?? this.isSensitive,
    );
  }
}