import '../models/quiz_topic_model.dart';
import '../services/firebase_database_service.dart';

class QuizRepository {
  final FirebaseDatabaseService _db;

  QuizRepository(this._db);

  Future<void> createTopic(QuizTopicModel topic) async {
    await _db.addQuizTopic(topic);
  }

  Future<void> editTopic(QuizTopicModel topic) async {
    await _db.updateQuizTopic(topic);
  }

  Future<void> removeTopic(String topicId, String category) async {
    await _db.deleteQuizTopic(topicId, category);
  }

  Stream<List<QuizTopicModel>> watchTopics(String category) {
    return _db.getQuizTopicsStream(category);
  }
}