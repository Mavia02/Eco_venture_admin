import '../../../models/stem_challenge_model.dart';


class StemChallengesState {
  final bool isLoading;
  final List<StemChallengeModel> challenges;
  final String? errorMessage;
  final bool isSuccess; // For showing Snackbars after Add/Edit/Delete

  StemChallengesState({
    this.isLoading = false,
    this.challenges = const [],
    this.errorMessage,
    this.isSuccess = false,
  });

  StemChallengesState copyWith({
    bool? isLoading,
    List<StemChallengeModel>? challenges,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return StemChallengesState(
      isLoading: isLoading ?? this.isLoading,
      challenges: challenges ?? this.challenges,
      errorMessage: errorMessage,
      // If isSuccess is not passed, default to false to reset it
      isSuccess: isSuccess ?? false,
    );
  }
}