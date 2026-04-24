import '../models/story_model.dart';
import '../services/firebase_database_service.dart';

class AdminStoryRepository {
  final FirebaseDatabaseService _db;

  AdminStoryRepository(this._db);

  Future<void> addStory(StoryModel story) async => await _db.addStory(story);
  Future<void> updateStory(StoryModel story) async => await _db.updateStory(story);
  Future<void> deleteStory(String id) async => await _db.deleteStory(id);
  Stream<List<StoryModel>> watchStories() => _db.getStoriesStream();
}