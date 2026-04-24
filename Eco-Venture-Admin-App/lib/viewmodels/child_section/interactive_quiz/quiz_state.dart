import '../../../models/quiz_topic_model.dart';


class QuizState {
  final bool isLoading;
  final List<QuizTopicModel> topics; // Changed from QuizModel
  final String? errorMessage;
  final bool isSuccess;

  QuizState({
    this.isLoading = false,
    this.topics = const [],
    this.errorMessage,
    this.isSuccess = false,
  });

  QuizState copyWith({
    bool? isLoading,
    List<QuizTopicModel>? topics,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return QuizState(
      isLoading: isLoading ?? this.isLoading,
      topics: topics ?? this.topics,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? false,
    );
  }
}