import 'package:eco_venture_admin_portal/viewmodels/child_section/Stem_challenges/stem_challenges_viewModel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/stem_challenge_model.dart';
import '../../../repositories/stem_challenges_repository.dart';
import '../interactive_quiz/quiz_provider.dart';
import 'stem_challenges_state.dart';


// --- REPOSITORY PROVIDER ---
// Pass the single FirebaseDatabaseService instance
final stemChallengesRepositoryProvider = Provider<StemChallengesRepository>((ref) {
  return StemChallengesRepository(ref.watch(firebaseDatabaseServiceProvider));
});

// --- VIEWMODEL PROVIDER ---
// Injects both the STEM Repo (DB) and Cloudinary Repo (Images)
final stemChallengesViewModelProvider =
StateNotifierProvider<StemChallengesViewModel, StemChallengesState>((ref) {
  return StemChallengesViewModel(
    ref.watch(stemChallengesRepositoryProvider),
    ref.watch(cloudinaryRepositoryProvider),
  );
});

// --- STREAM PROVIDER ---
// For fetching the list of challenges based on category ('All', 'Science', etc.)
final stemChallengesStreamProvider =
StreamProvider.family<List<StemChallengeModel>, String>((ref, category) {
  final repository = ref.watch(stemChallengesRepositoryProvider);
  return repository.watchChallenges(category);
});