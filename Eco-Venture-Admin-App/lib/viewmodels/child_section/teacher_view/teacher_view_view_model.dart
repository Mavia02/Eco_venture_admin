import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eco_venture_admin_portal/repositories/teacher_view_repo.dart';
import 'package:eco_venture_admin_portal/services/teacher_view_service.dart';
import 'package:eco_venture_admin_portal/viewmodels/child_section/teacher_view/teacher_view_state.dart';
import 'package:flutter/foundation.dart';

// Providers
final teacherRepositoryProvider = Provider((ref) => TeacherRepository());

// Service Provider (Injects Repository)
final teacherServiceProvider = Provider((ref) {
  final repository = ref.watch(teacherRepositoryProvider);
  return TeacherService(repository);
});

// Stream Provider (Consumes Service)
final teachersStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(teacherServiceProvider).getTeachersList();
});

class TeacherViewModel extends StateNotifier<TeacherState> {
  final TeacherService _service;
  final Ref _ref; // Logic: Added Ref to handle provider invalidation

  TeacherViewModel(this._service, this._ref) : super(TeacherState());

  Future<void> approve(String id) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.processTeacherApproval(id);

      // Logic: Force the stream to refresh so the UI updates the "Authorized" status immediately
      _ref.invalidate(teachersStreamProvider);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> rejectAndRemove(String id) async {
    state = state.copyWith(isLoading: true);
    try {
      // 1. Logic: Perform the Nuclear Wipe in the database
      await _service.executeNuclearWipe(id);

      // 2. Logic: CRITICAL FIX - Invalidate the stream provider.
      // This forces the UI to re-fetch the list, removing the deleted teacher instantly.
      _ref.invalidate(teachersStreamProvider);

      state = state.copyWith(isLoading: false);
      debugPrint("✅ State Refreshed: Teacher $id removed from UI");
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

// Final Action Provider
final teacherActionProvider = StateNotifierProvider<TeacherViewModel, TeacherState>((ref) {
  // Logic: Passing 'ref' to the ViewModel so it can invalidate other providers
  return TeacherViewModel(ref.watch(teacherServiceProvider), ref);
});