import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eco_venture_admin_portal/repositories/teacher_view_repo.dart';
import 'package:eco_venture_admin_portal/services/teacher_view_service.dart';
import 'package:eco_venture_admin_portal/viewmodels/child_section/teacher_view/teacher_view_state.dart';
import 'package:eco_venture_admin_portal/models/active_challenge_model.dart';
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

  TeacherViewModel(this._service) : super(TeacherState());

  Future<void> approve(String id) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.processTeacherApproval(id);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> rejectAndRemove(String id) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.executeNuclearWipe(id);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

// Final Action Provider
final teacherActionProvider = StateNotifierProvider<TeacherViewModel, TeacherState>((ref) {
  return TeacherViewModel(ref.watch(teacherServiceProvider));
});