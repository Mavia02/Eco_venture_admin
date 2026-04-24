import '../../../models/story_model.dart';


class AdminStoryState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final List<StoryModel> stories;

  AdminStoryState({this.isLoading = false, this.isSuccess = false, this.errorMessage, this.stories = const []});

  AdminStoryState copyWith({bool? isLoading, bool? isSuccess, String? errorMessage, List<StoryModel>? stories}) {
    return AdminStoryState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? false,
      errorMessage: errorMessage,
      stories: stories ?? this.stories,
    );
  }
}