
import '../../../models/teacher_request_model.dart';

class TeacherVerificationState {
  final bool isLoading;
  final String? errorMessage;
  final List<TeacherRequestModel> pendingTeachers;

  const TeacherVerificationState({
    this.isLoading = false,
    this.errorMessage,
    this.pendingTeachers = const [],
  });

  factory TeacherVerificationState.initial() {
    return const TeacherVerificationState(
      isLoading: false,
      errorMessage: null,
      pendingTeachers: [],
    );
  }

  TeacherVerificationState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<TeacherRequestModel>? pendingTeachers,
  }) {
    return TeacherVerificationState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // If null passed, keeps null (reset error)
      pendingTeachers: pendingTeachers ?? this.pendingTeachers,
    );
  }
}