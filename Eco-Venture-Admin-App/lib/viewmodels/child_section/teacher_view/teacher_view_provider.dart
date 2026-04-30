import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eco_venture_admin_portal/repositories/teacher_view_repo.dart';
import 'package:eco_venture_admin_portal/services/teacher_view_service.dart';
import 'package:eco_venture_admin_portal/viewmodels/child_section/teacher_view/teacher_view_view_model.dart';
import 'package:eco_venture_admin_portal/viewmodels/child_section/teacher_view/teacher_view_state.dart';

/// Logic: Dependency Injection Layer
/// 1. Provide the raw Data Source (Repository)
final teacherRepositoryProvider = Provider<TeacherRepository>((ref) {
  return TeacherRepository();
});

/// 2. Provide the Business Logic Layer (Service)
final teacherServiceProvider = Provider<TeacherService>((ref) {
  final repository = ref.watch(teacherRepositoryProvider);
  return TeacherService(repository);
});

/// 3. Provide the Real-time Data Stream (for the List UI)
final teachersStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final service = ref.watch(teacherServiceProvider);
  return service.getTeachersList();
});

/// 4. Provide the UI Logic & Action Handler (ViewModel)
final teacherActionProvider = StateNotifierProvider<TeacherViewModel, TeacherState>((ref) {
  final service = ref.watch(teacherServiceProvider);
  return TeacherViewModel(service);
});