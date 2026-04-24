import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/quiz_topic_model.dart';
import '../../../repositories/cloudinary_repository.dart';
import '../../../repositories/quiz_repoistory.dart';
import 'quiz_state.dart';

class QuizViewModel extends StateNotifier<QuizState> {
  final QuizRepository _repository;
  final CloudinaryRepository _cloudinaryRepository;

  QuizViewModel(this._repository, this._cloudinaryRepository) : super(QuizState());

  // --- HELPER: Process Images in Nested Structure (Topic -> Levels -> Questions) ---
  Future<QuizTopicModel> _processTopicImages(QuizTopicModel topic) async {
    List<QuizLevelModel> updatedLevels = [];

    // Loop through all Levels
    for (var level in topic.levels) {
      List<QuestionModel> updatedQuestions = [];

      // Loop through all Questions in Level
      for (var q in level.questions) {
        String? finalImgUrl = q.imageUrl;

        // Check if imageUrl exists and is a local file path
        if (finalImgUrl != null && !finalImgUrl.startsWith('http')) {
          final file = File(finalImgUrl);
          if (file.existsSync()) {
            // Upload using the specific QUIZ preset via Repository
            finalImgUrl = await _cloudinaryRepository.uploadQuizImage(
              file,
            );
            if (finalImgUrl == null) {
              // Handle error or keep null? Let's throw to stop save if critical,
              // or continue with null. Continuing prevents blocking save on image fail.
              print("Warning: Failed to upload image for question: ${q.question}");
              finalImgUrl = null;
            }
          } else {
            finalImgUrl = null; // File not found
          }
        }
        updatedQuestions.add(q.copyWith(imageUrl: finalImgUrl));
      }
      updatedLevels.add(level.copyWith(questions: updatedQuestions));
    }

    return topic.copyWith(levels: updatedLevels);
  }

  // --- ACTIONS ---

  // 1. Add Topic
  Future<void> addTopic(QuizTopicModel topic) async {
    state = state.copyWith(isLoading: true);
    try {
      // Step A: Upload all images in questions
      final processedTopic = await _processTopicImages(topic);

      // Step B: Save to Firebase
      await _repository.createTopic(processedTopic);

      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // 2. Update Topic
  Future<void> updateTopic(QuizTopicModel topic) async {
    state = state.copyWith(isLoading: true);
    try {
      final processedTopic = await _processTopicImages(topic);
      await _repository.editTopic(processedTopic);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // 3. Delete Topic
  Future<void> deleteTopic(String topicId, String category) async {
    try {
      await _repository.removeTopic(topicId, category);
      // No loading state needed for delete usually
    } catch (e) {
      state = state.copyWith(errorMessage: "Delete failed: $e");
    }
  }

  void resetSuccess() {
    state = state.copyWith(isSuccess: false);
  }
}