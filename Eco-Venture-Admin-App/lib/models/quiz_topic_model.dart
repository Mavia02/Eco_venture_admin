class QuizTopicModel {
  String? id;
  final String category;
  final String topicName;
  final String createdBy;
  final String creatorId;
  final List<QuizLevelModel> levels;

  // --- NEW FIELDS ---
  final List<String> tags;
  final bool isSensitive;

  QuizTopicModel({
    this.id,
    required this.category,
    required this.topicName,
    required this.createdBy,
    required this.creatorId,
    required this.levels,
    // --- Initialize New Fields ---
    this.tags = const [],
    this.isSensitive = false,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> levelsMap = {};
    for (var level in levels) {
      levelsMap[level.order.toString()] = level.toMap();
    }

    return {
      'topic_name': topicName,
      'created_by': createdBy,
      'creator_id': creatorId,
      'levels': levelsMap,
      // --- Serialize New Fields ---
      'tags': tags,
      'is_sensitive': isSensitive,
      // Adding a timestamp is helpful for Notifications sorting/filtering
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  factory QuizTopicModel.fromMap(String id, String category, Map<String, dynamic> map) {
    var rawLevels = map['levels'];
    List<QuizLevelModel> parsedLevels = [];

    if (rawLevels != null) {
      if (rawLevels is Map) {
        rawLevels.forEach((key, value) {
          if (value is Map) {
            parsedLevels.add(QuizLevelModel.fromMap(key.toString(), Map<String, dynamic>.from(value)));
          }
        });
      } else if (rawLevels is List) {
        for (var i = 0; i < rawLevels.length; i++) {
          final item = rawLevels[i];
          if (item != null && item is Map) {
            parsedLevels.add(QuizLevelModel.fromMap(i.toString(), Map<String, dynamic>.from(item)));
          }
        }
      }
    }

    parsedLevels.sort((a, b) => a.order.compareTo(b.order));

    // --- Parse Tags safely ---
    List<String> parsedTags = [];
    if (map['tags'] != null) {
      if (map['tags'] is List) {
        parsedTags = List<String>.from(map['tags']);
      } else if (map['tags'] is Map) {
        // Handle rare case where Firebase stores list as Map {"0": "tag1"}
        (map['tags'] as Map).forEach((k, v) => parsedTags.add(v.toString()));
      }
    }

    return QuizTopicModel(
      id: id,
      category: category,
      topicName: map['topic_name'] ?? '',
      createdBy: map['created_by'] ?? 'admin',
      creatorId: map['creator_id'] ?? '',
      levels: parsedLevels,
      // --- Deserialize New Fields ---
      tags: parsedTags,
      isSensitive: map['is_sensitive'] ?? false,
    );
  }

  QuizTopicModel copyWith({
    String? id,
    String? category,
    String? topicName,
    String? createdBy,
    String? creatorId,
    List<QuizLevelModel>? levels,
    // --- New Fields in CopyWith ---
    List<String>? tags,
    bool? isSensitive,
  }) {
    return QuizTopicModel(
      id: id ?? this.id,
      category: category ?? this.category,
      topicName: topicName ?? this.topicName,
      createdBy: createdBy ?? this.createdBy,
      creatorId: creatorId ?? this.creatorId,
      levels: levels ?? this.levels,
      // --- Assign New Fields ---
      tags: tags ?? this.tags,
      isSensitive: isSensitive ?? this.isSensitive,
    );
  }
}

// --- QuizLevelModel and QuestionModel remain UNCHANGED ---
// (Keep the code you sent for Level/Question models exactly as it is)
class QuizLevelModel {
  final int order;
  final String title;
  final int passingPercentage;
  final int points;
  final List<QuestionModel> questions;

  QuizLevelModel({
    required this.order,
    required this.title,
    required this.passingPercentage,
    required this.points,
    required this.questions,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'passing_percentage': passingPercentage,
      'points': points,
      'questions': questions.map((q) => q.toMap()).toList(),
    };
  }

  factory QuizLevelModel.fromMap(String orderKey, Map<String, dynamic> map) {
    return QuizLevelModel(
      order: int.tryParse(orderKey) ?? map['order'] ?? 1,
      title: map['title'] ?? '',
      passingPercentage: map['passing_percentage']?.toInt() ?? 60,
      points: map['points']?.toInt() ?? 0,
      questions: List<QuestionModel>.from(
        (map['questions'] as List<dynamic>? ?? []).map<QuestionModel>(
              (x) => QuestionModel.fromMap(Map<String, dynamic>.from(x as Map)),
        ),
      ),
    );
  }

  QuizLevelModel copyWith({
    int? order,
    String? title,
    int? passingPercentage,
    int? points,
    List<QuestionModel>? questions,
  }) {
    return QuizLevelModel(
      order: order ?? this.order,
      title: title ?? this.title,
      passingPercentage: passingPercentage ?? this.passingPercentage,
      points: points ?? this.points,
      questions: questions ?? this.questions,
    );
  }
}

class QuestionModel {
  final String question;
  final List<String> options;
  final String answer;
  final String? imageUrl;

  QuestionModel({
    required this.question,
    required this.options,
    required this.answer,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'answer': answer,
      'image_url': imageUrl,
    };
  }

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      answer: map['answer'] ?? '',
      imageUrl: map['image_url'],
    );
  }

  QuestionModel copyWith({
    String? question,
    List<String>? options,
    String? answer,
    String? imageUrl,
  }) {
    return QuestionModel(
      question: question ?? this.question,
      options: options ?? this.options,
      answer: answer ?? this.answer,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}