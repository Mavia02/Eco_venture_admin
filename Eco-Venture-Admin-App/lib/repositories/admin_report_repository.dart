
import '../services/admin_report_service.dart';
import '../../../../models/teacher_request_model.dart';

class AdminReportRepository {
  final AdminReportService _service;

  AdminReportRepository(this._service);

  // Pending List
  Stream<List<TeacherRequestModel>> watchPendingTeachers() {
    return _service.getPendingTeachersStream().map((snapshot) {
      return snapshot.docs
          .map((doc) => TeacherRequestModel.fromFirestore(doc))
          .toList();
    });
  }

  // NEW: Approved Count
  Stream<int> watchApprovedTeacherCount() {
    return _service.getActiveTeachersStream().map((snapshot) => snapshot.docs.length);
  }

  Future<void> approveTeacher(String uid) async => await _service.verifyTeacherAction(uid, 'approve');
  Future<void> rejectTeacher(String uid) async => await _service.verifyTeacherAction(uid, 'reject');
}