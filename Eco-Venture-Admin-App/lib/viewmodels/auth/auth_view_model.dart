import 'package:eco_venture_admin_portal/repositories/admin_firestore_repo.dart';
import 'package:eco_venture_admin_portal/services/shared_preferences_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/auth_repo.dart';
import 'auth_state.dart';

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepo _repo;

  AuthViewModel(this._repo) : super(AuthState.initial());


  Future<void> signInUser(
      String email,
      String password, {
        Function? onSuccess,
      }) async {
    state = state.copyWith(isEmailLoading: true, emailError: null);

    try {
      final user = await _repo.loginAdmin(email, password);

      if (user == null) {
        throw Exception("Invalid email or password");
      }

      // Save login data locally
      await SharedPreferencesHelper.instance.saveAdminId(user.aid);
      await SharedPreferencesHelper.instance.saveAdminEmail(user.email);

      // Ensure Firestore profile exists
      await AdminFirestoreRepo.instance.addAdminProfile(
        aid: user.aid,
        email: user.email,
      );

      // Update state
      state = state.copyWith(isEmailLoading: false, admin: user);

      if (onSuccess != null) onSuccess();
    } catch (e) {
      state = state.copyWith(isEmailLoading: false, emailError: e.toString());
    }
  }

  // ------------------- FORGOT PASSWORD -------------------
  Future<void> forgotPassword(String email, {Function? onSuccess}) async {
    state = state.copyWith(isEmailLoading: true, emailError: null);
    try {
      await _repo.forgotPassword(email);
      state = state.copyWith(isEmailLoading: false);

      if (onSuccess != null) onSuccess();
    } catch (e) {
      state = state.copyWith(isEmailLoading: false, emailError: e.toString());
    }
  }

  // ------------------- SIGN OUT -------------------
  Future<void> signOut({Function? onSuccess}) async {
    state = state.copyWith(isEmailLoading: true, emailError: null);

    try {
      // 1 Sign out from Firebase/AuthRepo
      await _repo.signOutAdmin();

      // 2 Clear all saved preferences
      await SharedPreferencesHelper.instance.clearAll();

      // 3 Reset state to initial
      state = AuthState.initial();

      // 4 Callback for navigation or UI action
      if (onSuccess != null) onSuccess();

      state = state.copyWith(isEmailLoading: false);
    } catch (e) {
      state = state.copyWith(isEmailLoading: false, emailError: e.toString());
    }
  }

  Future<void> deleteAdminAccount() async {
    try {
      // 1. Get admin ID from SharedPreferences
      final aid = await SharedPreferencesHelper.instance.getAdminId();

      // 2. Delete admin data from Firestore (optional but recommended)
      if (aid != null) {
        await AdminFirestoreRepo.instance.deleteAdminData(aid);
      }

      // 3. Delete from Firebase Authentication
      await _repo.deleteAccount();

      // 4. Clear all locally stored data
      await SharedPreferencesHelper.instance.clearAll();
    } catch (e) {
      state = state.copyWith(emailError: e.toString());
    }
  }














}
