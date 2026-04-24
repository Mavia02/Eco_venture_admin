import '../models/video_model.dart';
import '../services/firebase_database_service.dart';

class AdminVideoRepository {
  final FirebaseDatabaseService _db;

  AdminVideoRepository(this._db);

  Future<void> addVideo(VideoModel video) async => await _db.addVideo(video);
  Future<void> updateVideo(VideoModel video) async => await _db.updateVideo(video);
  Future<void> deleteVideo(String id) async => await _db.deleteVideo(id);
  Stream<List<VideoModel>> watchVideos() => _db.getVideosStream();
}