import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../repositories/admin_story_repoistory.dart';
import '../../../repositories/admin_video_repository.dart';
import '../../../repositories/cloudinary_repository.dart';
import '../../../services/cloudinary_service.dart';
import '../../../services/firebase_database_service.dart';
import 'admin_video_view_model.dart';
import 'admin_story_view_model.dart';
import 'admin_video_state.dart';
import 'admin_story_state.dart';

// 1. Services
final firebaseDatabaseServiceProvider = Provider((ref) => FirebaseDatabaseService());
final cloudinaryServiceProvider = Provider((ref) => CloudinaryService());

// 2. Repositories
final adminVideoRepositoryProvider = Provider<AdminVideoRepository>((ref) {
  return AdminVideoRepository(ref.watch(firebaseDatabaseServiceProvider));
});

final adminStoryRepositoryProvider = Provider<AdminStoryRepository>((ref) {
  return AdminStoryRepository(ref.watch(firebaseDatabaseServiceProvider));
});

final cloudinaryRepositoryProvider = Provider<CloudinaryRepository>((ref) {
  return CloudinaryRepository(
    ref.watch(cloudinaryServiceProvider),
    ref.watch(firebaseDatabaseServiceProvider),
  );
});

// 3. ViewModels
final adminVideoViewModelProvider = StateNotifierProvider<AdminVideoViewModel, AdminVideoState>((ref) {
  return AdminVideoViewModel(
    ref.watch(adminVideoRepositoryProvider),
    ref.watch(cloudinaryRepositoryProvider),
  );
});

final adminMultimediaViewModelProvider = StateNotifierProvider<AdminStoryViewModel, AdminStoryState>((ref) {
  return AdminStoryViewModel(
    ref.watch(adminStoryRepositoryProvider),
    ref.watch(cloudinaryRepositoryProvider),
  );
});