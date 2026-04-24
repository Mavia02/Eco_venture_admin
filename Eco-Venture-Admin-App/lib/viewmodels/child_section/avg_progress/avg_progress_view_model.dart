import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eco_venture_admin_portal/repositories/avg_progress_repo.dart';
import 'avg_progress_state.dart';

/// Logic: Manages the business logic for calculating and updating global progress.
/// It orchestrates the flow from the Repository to the UI-bound state.
class AvgProgressViewModel extends StateNotifier<AvgProgressState> {
  final ProgressAggregationRepo _repo;

  AvgProgressViewModel(this._repo) : super(AvgProgressState.initial());

  /// Logic: Triggers the background calculation of global stats (50/50 weightage).
  /// Updates the state to reflect loading, error, or successfully aggregated data.
  Future<void> fetchGlobalProgress() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _repo.getGlobalStats();
      state = state.copyWith(isLoading: false, stats: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}