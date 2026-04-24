import '../../../models/video_model.dart';


class AdminVideoState {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;
  final List<VideoModel> videos;

  AdminVideoState({this.isLoading = false, this.isSuccess = false, this.errorMessage, this.videos = const []});

  AdminVideoState copyWith({bool? isLoading, bool? isSuccess, String? errorMessage, List<VideoModel>? videos}) {
    return AdminVideoState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? false,
      errorMessage: errorMessage,
      videos: videos ?? this.videos,
    );
  }
}