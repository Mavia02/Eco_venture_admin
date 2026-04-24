import 'package:flutter_riverpod/flutter_riverpod.dart';
// Logic: Corrected the path to include 'child_section' to resolve the repo error
import 'package:eco_venture_admin_portal/repositories/active_challenge_repo.dart';
import 'active_challenge_state.dart';

/// Logic: ViewModel responsible for managing the state of currently active challenges.
/// It fetches data from the ActiveChallengeRepo and handles loading/error states.
class ActiveChallengeViewModel extends StateNotifier<ActiveChallengeState> {
  final ActiveChallengeRepo _repo;

  ActiveChallengeViewModel(this._repo) : super(ActiveChallengeState.initial());

  /// Logic: Fetches the list of active challenges from the repository.
  /// Updates the state with the list and the total count for the dashboard card.
  Future<void> fetchActiveStats() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _repo.getActiveChallenges();

      state = state.copyWith(
        isLoading: false,
        activeChallenges: list,
        totalActiveCount: list.length,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
