import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_venture_admin_portal/services/admin_report_service.dart';

class TeacherRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Logic: Use the existing AdminReportService for backend communication
  final AdminReportService _reportService = AdminReportService();

  /// Logic: Stream of APPROVED/ACTIVE teachers from the 'users' collection
  /// This ensures the Directory only shows verified teachers with 'active' status.
  Stream<List<Map<String, dynamic>>> getTeachersStream() {
    return _reportService.getActiveTeachersStream().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          ...data,
          'id': doc.id,
          // Logic: Per your backend switch-case, 'active' is the status for verified teachers.
          // This fixes the UI label showing "Pending Approval" correctly.
          'isApproved': data['status'] == 'active',
        };
      }).toList();
    });
  }

  /// Logic: Approve Teacher via the backend service
  Future<void> approveTeacher(String teacherId) async {
    // Logic: Trigger the backend HTTP call for 'approve'
    await _reportService.verifyTeacherAction(teacherId, 'approve');
  }

  /// Logic: The "Nuclear Wipe"
  /// This calls the 'delete' action in your backend to run admin.auth().deleteUser()
  /// and perform database cleanup.
  Future<void> rejectAndWipeTeacher(String teacherId) async {
    try {
      // 1. Logic: Call the backend with 'delete' action to trigger Auth removal
      await _reportService.verifyTeacherAction(teacherId, 'delete');

      // 2. Logic: Local cleanup batch as a secondary safety measure
      final batch = _firestore.batch();

      // Wipe the user document
      batch.delete(_firestore.collection('users').doc(teacherId));

      // Wipe auxiliary teacher collection if it exists
      batch.delete(_firestore.collection('teachers').doc(teacherId));

      // 3. Logic: Cleanup associated modules
      final modules = await _firestore.collection('modules').where('teacherId', isEqualTo: teacherId).get();
      for (var doc in modules.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception("Nuclear Wipe Failed: $e");
    }
  }
}