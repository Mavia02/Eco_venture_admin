import 'package:eco_venture_admin_portal/models/avg_progress_model.dart';

/// Logic: Defines the immutable state for the Average Progress dashboard.
class AvgProgressState {
  final bool isLoading;
  final String? error;
  final AvgProgressModel stats;

  AvgProgressState({
    required this.isLoading,
    this.error,
    required this.stats,
  });

  /// Logic: Initial state with empty model and loading set to false.
  factory AvgProgressState.initial() => AvgProgressState(
    isLoading: false,
    stats: AvgProgressModel.empty(),
  );

  /// Logic: Standard copyWith for immutable state updates.
  AvgProgressState copyWith({
    bool? isLoading,
    String? error,
    AvgProgressModel? stats,
  }) {
    return AvgProgressState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      stats: stats ?? this.stats,
    );
  }
}