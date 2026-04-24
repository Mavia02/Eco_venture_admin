import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../repositories/admin_report_repository.dart';
import '../../../services/admin_report_service.dart';
import 'teacher_verification_view_model.dart';
import 'teacher_verification_state.dart';

// Service & Repo
final adminReportServiceProvider = Provider((ref) => AdminReportService());
final adminReportRepositoryProvider = Provider((ref) => AdminReportRepository(ref.watch(adminReportServiceProvider)));

// ViewModel (Pending List)
final teacherVerificationViewModelProvider =
StateNotifierProvider<TeacherVerificationViewModel, TeacherVerificationState>((ref) {
  return TeacherVerificationViewModel(ref.watch(adminReportRepositoryProvider));
});

// NEW: Approved Count Provider
final approvedTeacherCountProvider = StreamProvider<int>((ref) {
  return ref.watch(adminReportRepositoryProvider).watchApprovedTeacherCount();
});