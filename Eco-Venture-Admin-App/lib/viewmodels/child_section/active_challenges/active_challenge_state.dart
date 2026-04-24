import 'package:eco_venture_admin_portal/models/active_challenge_model.dart';

class ActiveChallengeState {
  final bool isLoading;
  final String? error;
  final List<ActiveChallengeModel> activeChallenges;
  final int totalActiveCount;

  const ActiveChallengeState({
    required this.isLoading,
    this.error,
    required this.activeChallenges,
    required this.totalActiveCount,
  });

  factory ActiveChallengeState.initial() => const ActiveChallengeState(
    isLoading: false,
    error: null,
    activeChallenges: [],
    totalActiveCount: 0,
  );

  ActiveChallengeState copyWith({
    bool? isLoading,
    String? error,
    List<ActiveChallengeModel>? activeChallenges,
    int? totalActiveCount,
  }) {
    return ActiveChallengeState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      activeChallenges: activeChallenges ?? this.activeChallenges,
      totalActiveCount: totalActiveCount ?? this.totalActiveCount,
    );
  }
}