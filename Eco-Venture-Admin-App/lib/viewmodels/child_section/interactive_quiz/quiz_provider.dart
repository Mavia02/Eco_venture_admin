import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/quiz_topic_model.dart';
import '../../../repositories/cloudinary_repository.dart';
import '../../../repositories/quiz_repoistory.dart';
import '../../../services/cloudinary_service.dart';
import '../../../services/firebase_database_service.dart';
import 'quiz_view_model.dart';
import 'quiz_state.dart';


// Services
final firebaseDatabaseServiceProvider = Provider<FirebaseDatabaseService>((ref) => FirebaseDatabaseService());
final cloudinaryServiceProvider = Provider<CloudinaryService>((ref) => CloudinaryService());

// Repositories
final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  return QuizRepository(ref.watch(firebaseDatabaseServiceProvider));
});

final cloudinaryRepositoryProvider = Provider<CloudinaryRepository>((ref) {
  return CloudinaryRepository(
    ref.watch(cloudinaryServiceProvider),
    ref.watch(firebaseDatabaseServiceProvider),
  );
});

// ViewModel
final quizViewModelProvider = StateNotifierProvider<QuizViewModel, QuizState>((ref) {
  return QuizViewModel(
    ref.watch(quizRepositoryProvider),
    ref.watch(cloudinaryRepositoryProvider),
  );
});

// Stream
final quizListStreamProvider = StreamProvider.family<List<QuizTopicModel>, String>((ref, category) {
  final repository = ref.watch(quizRepositoryProvider);
  return repository.watchTopics(category);
});