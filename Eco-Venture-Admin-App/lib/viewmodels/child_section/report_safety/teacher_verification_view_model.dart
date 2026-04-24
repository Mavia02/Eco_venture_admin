import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../repositories/admin_report_repository.dart';
import 'teacher_verification_state.dart';

class TeacherVerificationViewModel extends StateNotifier<TeacherVerificationState> {
  final AdminReportRepository _repository;

  TeacherVerificationViewModel(this._repository) : super(TeacherVerificationState.initial()) {
    _initSubscription();
  }

  void _initSubscription() {
    _repository.watchPendingTeachers().listen((teachers) {
      state = state.copyWith(pendingTeachers: teachers, errorMessage: null);
    }, onError: (e) {
      state = state.copyWith(errorMessage: e.toString());
    });
  }

  Future<void> approveTeacher(String uid) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.approveTeacher(uid);
      // No manual list refresh needed; Stream handles it.
    } catch (e) {
      state = state.copyWith(errorMessage: "Approval Failed: $e");
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> rejectTeacher(String uid) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.rejectTeacher(uid);
    } catch (e) {
      state = state.copyWith(errorMessage: "Rejection Failed: $e");
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}