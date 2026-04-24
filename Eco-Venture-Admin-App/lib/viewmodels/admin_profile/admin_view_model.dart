import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/admin_firestore_repo.dart';
import '../../services/cloudinary_service.dart';
import '../../services/shared_preferences_helper.dart';
import 'admin_profile_state.dart';

class AdminViewModel extends StateNotifier<AdminProfileState> {
  final AdminFirestoreRepo _repo;
  final CloudinaryService _cloudinaryService = CloudinaryService();

  AdminViewModel(this._repo) : super(AdminProfileState.initial());

  //  Fetch admin profile from Firestore
  Future<void> fetchUserProfile(String aid) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _repo.getAdminProfile(aid);

      if (data != null) {
        //  Update local cache (fixed: property name imageUrl)
        await SharedPreferencesHelper.instance.saveAdminName(data.name ?? '');
        await SharedPreferencesHelper.instance.saveAdminEmail(data.email ?? '');
        await SharedPreferencesHelper.instance.saveAdminImgUrl(data.imgUrl ?? '');
      }

      //  Update state with fetched profile
      state = state.copyWith(isLoading: false, adminProfile: data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  //  Upload + Save Profile Image
  Future<void> uploadAndSaveProfileImage({
    required String aid,
    required File imageFile,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final imageUrl = await _cloudinaryService.uploadProfileImage(imageFile);

      if (imageUrl != null) {
        //  1. Update Firestore first
        await _repo.updateAdminImageUrl(aid, imageUrl);

        //  2. Update local state immediately (no waiting)
        final updatedProfile = state.adminProfile?.copyWith(imgUrl: imageUrl);
        state = state.copyWith(adminProfile: updatedProfile);

        //  3. Save locally — after state updated
        await SharedPreferencesHelper.instance.saveAdminImgUrl(imageUrl);

        //  4. Small delay to let Firestore update propagate
        await Future.delayed(const Duration(milliseconds: 400));

        //  5. Re-fetch to ensure Firestore and local match
        await fetchUserProfile(aid);
      } else {
        throw Exception("Image upload failed");
      }

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  //  Upload + Save Profile Email
  Future<void> uploadAndSaveProfileEmail({
    required String aid,
    required String email,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repo.updateAdminEmail(aid, email);
      await SharedPreferencesHelper.instance.saveAdminEmail(email);

      //  Refresh Firestore data locally
      await fetchUserProfile(aid);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  //  Upload + Save Profile Name
  Future<void> uploadAndSaveProfileName({
    required String aid,
    required String name,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _repo.updateAdminName(aid, name);
      await SharedPreferencesHelper.instance.saveAdminName(name);

      //  Refresh state with latest Firestore data
      await fetchUserProfile(aid);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
