import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eco_venture_admin_portal/repositories/active_challenge_repo.dart';
import 'active_challenge_view_model.dart';
import 'active_challenge_state.dart';

/// Logic: Provides a globally accessible instance of the ActiveChallengeViewModel.
/// It injects the ActiveChallengeRepo to allow the ViewModel to communicate with Firebase.
final activeChallengeProvider =
StateNotifierProvider<ActiveChallengeViewModel, ActiveChallengeState>((ref) {
  return ActiveChallengeViewModel(ActiveChallengeRepo.instance);
});