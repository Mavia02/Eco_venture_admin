import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/story_model.dart';
import '../../../repositories/admin_story_repoistory.dart';
import '../../../repositories/cloudinary_repository.dart';
import 'admin_story_state.dart';


class AdminStoryViewModel extends StateNotifier<AdminStoryState> {
  final AdminStoryRepository _repository;
  final CloudinaryRepository _cloudinaryRepository;
  StreamSubscription? _sub;

  AdminStoryViewModel(this._repository, this._cloudinaryRepository) : super(AdminStoryState());

  void loadStories() {
    _sub?.cancel();
    state = state.copyWith(isLoading: true);
    _sub = _repository.watchStories().listen(
          (data) => state = state.copyWith(isLoading: false, stories: data),
      onError: (e) => state = state.copyWith(isLoading: false, errorMessage: e.toString()),
    );
  }

  Future<void> addStory(StoryModel story) async {
    state = state.copyWith(isLoading: true);
    try {
      final processed = await _processStoryFiles(story);
      await _repository.addStory(processed);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> updateStory(StoryModel story) async {
    state = state.copyWith(isLoading: true);
    try {
      final processed = await _processStoryFiles(story);
      await _repository.updateStory(processed);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> deleteStory(String id) async {
    try {
      await _repository.deleteStory(id);
    } catch (e) {
      state = state.copyWith(errorMessage: "Delete failed: $e");
    }
  }

  Future<StoryModel> _processStoryFiles(StoryModel story) async {
    String? coverUrl = story.thumbnailUrl;

    if (coverUrl != null && !coverUrl.startsWith('http')) {
      final file = File(coverUrl);
      if(file.existsSync()) {
        coverUrl = await _cloudinaryRepository.uploadMultimediaFile(file, isVideo: false);
      }
    }

    List<StoryPage> updatedPages = [];
    for (var page in story.pages) {
      String? pageImg = page.imageUrl;
      if (pageImg != null && pageImg.isNotEmpty && !pageImg.startsWith('http')) {
        final file = File(pageImg);
        if(file.existsSync()) {
          pageImg = await _cloudinaryRepository.uploadMultimediaFile(file, isVideo: false);
        }
      }
      updatedPages.add(StoryPage(text: page.text, imageUrl: pageImg ?? ''));
    }

    return story.copyWith(thumbnailUrl: coverUrl, pages: updatedPages);
  }

  void resetSuccess() => state = state.copyWith(isSuccess: false);

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}