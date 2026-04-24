import 'package:eco_venture_admin_portal/models/children_summary_model.dart';

class ChildDashboardState {
  final bool isLoading;
  final String? error;
  final ChildrenSummaryModel summary;
  final List<Map<String, dynamic>> teacherStudents;
  final List<Map<String, dynamic>> directStudents;

  const ChildDashboardState({
    required this.isLoading,
    this.error,
    required this.summary,
    required this.teacherStudents,
    required this.directStudents,
  });

  factory ChildDashboardState.initial() {
    return ChildDashboardState(
      isLoading: false,
      error: null,
      summary: ChildrenSummaryModel.empty(),
      teacherStudents: [],
      directStudents: [],
    );
  }

  ChildDashboardState copyWith({
    bool? isLoading,
    String? error,
    ChildrenSummaryModel? summary,
    List<Map<String, dynamic>>? teacherStudents,
    List<Map<String, dynamic>>? directStudents,
  }) {
    return ChildDashboardState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      summary: summary ?? this.summary,
      teacherStudents: teacherStudents ?? this.teacherStudents,
      directStudents: directStudents ?? this.directStudents,
    );
  }
}