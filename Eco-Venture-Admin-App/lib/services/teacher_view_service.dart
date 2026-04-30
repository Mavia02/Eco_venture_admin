import 'package:eco_venture_admin_portal/repositories/teacher_view_repo.dart';
class TeacherService {
  final TeacherRepository _repository;

  TeacherService(this._repository);

  /// Logic: Business rule for teacher approval
  Future<void> processTeacherApproval(String teacherId) async {
    // You can add validation logic here (e.g., checking if admin has permissions)
    await _repository.approveTeacher(teacherId);
  }

  /// Logic: The "Nuclear Wipe" Business Logic
  /// Orchestrates the deletion of the profile and all related content
  Future<void> executeNuclearWipe(String teacherId) async {
    try {
      // 1. Logic: Perform the data wipe via repository
      await _repository.rejectAndWipeTeacher(teacherId);

      // 2. Logic: You could add more service-level tasks here
      // like logging the deletion or sending an automated rejection email
    } catch (e) {
      throw Exception("Failed to execute nuclear wipe: $e");
    }
  }

  /// Logic: Get real-time list of teachers
  Stream<List<Map<String, dynamic>>> getTeachersList() {
    return _repository.getTeachersStream();
  }
}