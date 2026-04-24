import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eco_venture_admin_portal/repositories/admin_firestore_repo.dart';
import 'package:eco_venture_admin_portal/models/children_summary_model.dart';
import 'child_dashboard_state.dart';

class ChildDashboardViewModel extends StateNotifier<ChildDashboardState> {
  final AdminFirestoreRepo _repo;

  ChildDashboardViewModel(this._repo) : super(ChildDashboardState.initial());

  Future<void> fetchDashboardStats() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // 1. Fetch data in parallel for efficiency
      final results = await Future.wait([
        _repo.getAllChildren(),
        _repo.getAllTeachers(),
      ]);

      final List<Map<String, dynamic>> childrenData = results[0];
      final List<Map<String, dynamic>> teachersData = results[1];

      // 2. Create a lookup map for teacher names
      // uid is used as the key for matching teacher_id from children documents
      Map<String, String> teacherLookup = {};
      for (var teacher in teachersData) {
        final String uid = teacher['uid'] ?? '';
        final String name = teacher['name'] ?? teacher['displayName'] ?? "Unknown Teacher";
        if (uid.isNotEmpty) teacherLookup[uid] = name;
      }

      List<Map<String, dynamic>> teacherList = [];
      List<Map<String, dynamic>> directList = [];

      for (var data in childrenData) {
        final String? teacherId = data['teacher_id'];

        if (teacherId != null && teacherId.isNotEmpty) {
          // Logic: Inject teacher name into the student data map for the UI
          data['teacher_name'] = teacherLookup[teacherId] ?? "Unknown Teacher";
          teacherList.add(data);
        } else {
          directList.add(data);
        }
      }

      final summary = ChildrenSummaryModel(
        totalChildren: childrenData.length,
        teacherRegistered: teacherList.length,
        directRegistered: directList.length,
      );

      state = state.copyWith(
        isLoading: false,
        summary: summary,
        teacherStudents: teacherList,
        directStudents: directList,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}