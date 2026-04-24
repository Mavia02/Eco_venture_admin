import 'dart:io';
import '../services/cloudinary_service.dart';
import '../services/firebase_database_service.dart';

class CloudinaryRepository {
  final CloudinaryService _cloudinaryService;
  final FirebaseDatabaseService _databaseService;

  CloudinaryRepository(this._cloudinaryService, this._databaseService);

  // ==================================================
  //  MODULE SPECIFIC UPLOAD FUNCTIONS
  // ==================================================

  // 1. STEM CHALLENGES
  Future<String?> uploadStemImage(File file) async {
    return await _cloudinaryService.uploadStemImage(file);
  }

  // 2. QUIZZES
  Future<String?> uploadQuizImage(File file) async {
    return await _cloudinaryService.uploadQuizImage(file);
  }

  // 3. MULTIMEDIA (Videos & Thumbnails)
  // Returns the URL String
  Future<String?> uploadMultimediaFile(File file, {bool isVideo = false}) async {
    return await _cloudinaryService.uploadMultimediaFile(file, isVideo: isVideo);
  }

  // 4. QR TREASURE HUNT
  Future<String?> uploadQrHuntImage(File file) async {
    return await _cloudinaryService.uploadQrHuntImage(file);
  }

  // 5. ADMIN PROFILE
  Future<String?> uploadProfileImage(File file) async {
    return await _cloudinaryService.uploadProfileImage(file);
  }

  // --- HELPER: DELETE ---
  Future<void> deleteImage(String imageUrl) async {
    await _cloudinaryService.deleteImage(imageUrl);
  }
}