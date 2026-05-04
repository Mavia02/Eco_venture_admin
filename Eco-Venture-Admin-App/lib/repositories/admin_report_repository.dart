import '../services/admin_report_service.dart';
import '../../../../models/teacher_request_model.dart';
import '../../../../models/report_model.dart';

class AdminReportRepository {
  final AdminReportService _service;

  AdminReportRepository(this._service);

  // --- EXISTING LOGIC: TEACHER VERIFICATION (PRESERVED) ---

  Stream<List<TeacherRequestModel>> watchPendingTeachers() {
    return _service.getPendingTeachersStream().map((snapshot) {
      return snapshot.docs
          .map((doc) => TeacherRequestModel.fromFirestore(doc))
          .toList();
    });
  }

  Stream<int> watchApprovedTeacherCount() {
    return _service.getActiveTeachersStream().map((snapshot) => snapshot.docs.length);
  }

  Future<void> approveTeacher(String uid) async => await _service.verifyTeacherAction(uid, 'approve');
  Future<void> rejectTeacher(String uid) async => await _service.verifyTeacherAction(uid, 'reject');

  // --- NEW LOGIC: UNIFIED REPORTS ---

  /// Logic: Watches all merged reports from Child, Teacher, and Parent
  Stream<List<ReportModel>> watchAllReports() {
    return _service.getAllAdminReportsStream();
  }

  /// Logic: Triggers the resolution process
  Future<void> resolveReport(String reportId, String source) async {
    await _service.resolveReportAction(reportId, source);
  }
}