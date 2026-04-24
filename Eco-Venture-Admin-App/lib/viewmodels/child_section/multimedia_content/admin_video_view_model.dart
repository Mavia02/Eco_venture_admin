import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/video_model.dart';
import '../../../repositories/admin_video_repository.dart';
import '../../../repositories/cloudinary_repository.dart';
import 'admin_video_state.dart';

class AdminVideoViewModel extends StateNotifier<AdminVideoState> {
  final AdminVideoRepository _repository;
  final CloudinaryRepository _cloudinaryRepository;
  StreamSubscription? _sub;

  AdminVideoViewModel(this._repository, this._cloudinaryRepository) : super(AdminVideoState());

  void loadVideos() {
    _sub?.cancel();
    state = state.copyWith(isLoading: true);
    _sub = _repository.watchVideos().listen(
          (data) => state = state.copyWith(isLoading: false, videos: data),
      onError: (e) => state = state.copyWith(isLoading: false, errorMessage: e.toString()),
    );
  }

  Future<void> addVideo(VideoModel video) async {
    state = state.copyWith(isLoading: true);
    try {
      final processed = await _processVideoFiles(video);
      await _repository.addVideo(processed);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> updateVideo(VideoModel video) async {
    state = state.copyWith(isLoading: true);
    try {
      final processed = await _processVideoFiles(video);
      await _repository.updateVideo(processed);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> deleteVideo(String id) async {
    try {
      await _repository.deleteVideo(id);
    } catch (e) {
      state = state.copyWith(errorMessage: "Delete failed: $e");
    }
  }

  // Helper: Upload Files if local
  Future<VideoModel> _processVideoFiles(VideoModel video) async {
    String finalVideoUrl = video.videoUrl;
    String? finalThumbUrl = video.thumbnailUrl;

    if (video.videoUrl.isNotEmpty && !video.videoUrl.startsWith('http')) {
      final file = File(video.videoUrl);
      if(file.existsSync()) {
        final uploaded = await _cloudinaryRepository.uploadMultimediaFile(file, isVideo: true);
        if(uploaded != null) finalVideoUrl = uploaded;
      }
    }

    if (video.thumbnailUrl != null && !video.thumbnailUrl!.startsWith('http')) {
      final file = File(video.thumbnailUrl!);
      if(file.existsSync()) {
        final uploaded = await _cloudinaryRepository.uploadMultimediaFile(file, isVideo: false);
        if(uploaded != null) finalThumbUrl = uploaded;
      }
    }

    return video.copyWith(videoUrl: finalVideoUrl, thumbnailUrl: finalThumbUrl);
  }

  void resetSuccess() => state = state.copyWith(isSuccess: false);

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}