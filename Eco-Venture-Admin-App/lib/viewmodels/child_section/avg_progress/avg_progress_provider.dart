import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eco_venture_admin_portal/repositories/avg_progress_repo.dart';
import 'avg_progress_view_model.dart';
import 'avg_progress_state.dart';

/// Logic: Provides a globally accessible instance of the AvgProgressViewModel.
/// It injects the singleton instance of the ProgressAggregationRepo.
final avgProgressProvider =
StateNotifierProvider<AvgProgressViewModel, AvgProgressState>((ref) {
  return AvgProgressViewModel(ProgressAggregationRepo.instance);
});