import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/stem_challenge_model.dart';
import '../../../repositories/cloudinary_repository.dart';
import '../../../repositories/stem_challenges_repository.dart';
import 'stem_challenges_state.dart';


class StemChallengesViewModel extends StateNotifier<StemChallengesState> {
  final StemChallengesRepository _repository;
  final CloudinaryRepository _cloudinaryRepository;

  StemChallengesViewModel(this._repository, this._cloudinaryRepository)
      : super(StemChallengesState());

  // --- HELPER: Upload Image if needed ---
  Future<StemChallengeModel> _processImage(StemChallengeModel challenge) async {
    String? finalImageUrl = challenge.imageUrl;

    // Check if imageUrl exists and is a local file path
    if (finalImageUrl != null && !finalImageUrl.startsWith('http')) {
      final file = File(finalImageUrl);
      if (file.existsSync()) {
        // Upload using the specific STEM preset via Repository
        finalImageUrl = await _cloudinaryRepository.uploadStemImage(
          file,
        );
        if (finalImageUrl == null) {
          throw Exception("Failed to upload Challenge Image.");
        }
      } else {
        finalImageUrl = null; // File missing
      }
    }

    // Return copy with proper URL
    return challenge.copyWith(imageUrl: finalImageUrl);
  }

  // --- ACTIONS ---

  // 1. Add Challenge
  Future<void> addChallenge(StemChallengeModel challenge) async {
    state = state.copyWith(isLoading: true);
    try {
      // Step A: Upload Image
      final challengeWithUrl = await _processImage(challenge);

      // Step B: Save to Firebase
      await _repository.addChallenge(challengeWithUrl);

      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // 2. Update Challenge
  Future<void> updateChallenge(StemChallengeModel challenge) async {
    state = state.copyWith(isLoading: true);
    try {
      // Step A: Upload Image (only if changed to a local file)
      final challengeWithUrl = await _processImage(challenge);

      // Step B: Update in Firebase
      await _repository.updateChallenge(challengeWithUrl);

      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // 3. Delete Challenge
  Future<void> deleteChallenge(String challengeId, String category) async {
    try {
      await _repository.deleteChallenge(challengeId, category);
    } catch (e) {
      state = state.copyWith(errorMessage: "Delete failed: ${e.toString()}");
    }
  }

  // Reset success flag after UI handles it
  void resetSuccess() {
    state = state.copyWith(isSuccess: false);
  }
}