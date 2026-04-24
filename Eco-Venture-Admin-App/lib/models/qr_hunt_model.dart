class QrHuntModel {
  final String? id;
  final String? adminId;
  final String title;
  final int points;
  final String difficulty; // Easy, Medium, Hard
  final List<String> clues;
  final DateTime createdAt;

  // --- NEW FIELDS ---
  final List<String> tags;
  final bool isSensitive;

  QrHuntModel({
    this.id,
    this.adminId,
    required this.title,
    required this.points,
    required this.difficulty,
    required this.clues,
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
      'points': points,
      'difficulty': difficulty,
      'clues': clues,
      'createdAt': createdAt.toIso8601String(),
      // --- Serialize New Fields ---
      'tags': tags,
      'isSensitive': isSensitive,
    };
  }

  factory QrHuntModel.fromMap(String id, Map<String, dynamic> map) {
    return QrHuntModel(
      id: id,
      adminId: map['adminId'],
      title: map['title'] ?? '',
      points: (map['points'] as num? ?? 0).toInt(),
      difficulty: map['difficulty'] ?? 'Easy',
      clues: List<String>.from(map['clues'] ?? []),
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      // --- Deserialize New Fields ---
      tags: List<String>.from(map['tags'] ?? []),
      isSensitive: map['isSensitive'] ?? false,
    );
  }

  QrHuntModel copyWith({
    String? id,
    String? adminId,
    String? title,
    int? points,
    String? difficulty,
    List<String>? clues,
    DateTime? createdAt,
    // --- New Fields in CopyWith ---
    List<String>? tags,
    bool? isSensitive,
  }) {
    return QrHuntModel(
      id: id ?? this.id,
      adminId: adminId ?? this.adminId,
      title: title ?? this.title,
      points: points ?? this.points,
      difficulty: difficulty ?? this.difficulty,
      clues: clues ?? this.clues,
      createdAt: createdAt ?? this.createdAt,
      // --- Assign New Fields ---
      tags: tags ?? this.tags,
      isSensitive: isSensitive ?? this.isSensitive,
    );
  }
}