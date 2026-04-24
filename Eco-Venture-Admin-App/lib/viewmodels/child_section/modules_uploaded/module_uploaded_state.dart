import 'package:eco_venture_admin_portal/models/modules_uploaded_model.dart';

/// Logic: Defines the immutable state for the Modules Uploaded dashboard.
class ModuleUploadedState {
  final bool isLoading;
  final String? error;
  final ModuleStatsModel stats;

  const ModuleUploadedState({
    required this.isLoading,
    this.error,
    required this.stats,
  });

  /// Logic: Initial state with empty stats and loading set to false.
  factory ModuleUploadedState.initial() {
    return ModuleUploadedState(
      isLoading: false,
      error: null,
      stats: ModuleStatsModel.empty(),
    );
  }

  /// Logic: Standard copyWith for immutable state updates.
  ModuleUploadedState copyWith({
    bool? isLoading,
    String? error,
    ModuleStatsModel? stats,
  }) {
    return ModuleUploadedState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      stats: stats ?? this.stats,
    );
  }
}