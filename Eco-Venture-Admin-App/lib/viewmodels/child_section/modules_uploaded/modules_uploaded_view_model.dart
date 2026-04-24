import 'package:flutter_riverpod/flutter_riverpod.dart';
// Logic: Using absolute package imports to ensure proper path resolution
// and matching the folder structure identified in the images.
import 'package:eco_venture_admin_portal/repositories/module_uploaded_repo.dart';
import 'package:eco_venture_admin_portal/models/modules_uploaded_model.dart';
import 'module_uploaded_state.dart';

/// Logic: ViewModel responsible for managing the state of uploaded modules.
/// It orchestrates the data retrieval from the repository and partitions it
/// for the Admin Library and Teacher Uploads tabs.
class ModulesUploadedViewModel extends StateNotifier<ModuleUploadedState> {
  final ModuleRepo _repo;

  ModulesUploadedViewModel(this._repo) : super(ModuleUploadedState.initial());

  /// Logic: Fetches the entire module library and performs categorization.
  /// This addresses the "0" issue by ensuring role matching is case-insensitive and trimmed.
  Future<void> fetchModuleStats() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Step 1: Fetch all tasks/modules from the RTDB via the Repo
      final List<ModuleContentModel> all = await _repo.getModuleLibrary();

      List<ModuleContentModel> admin = [];
      List<ModuleContentModel> teacher = [];
      Map<String, int> catCounts = {};

      // Step 2: Iterate and categorize
      for (var m in all) {
        // Track counts per category (Quiz, STEM, etc.) for dashboard charts
        catCounts[m.category] = (catCounts[m.category] ?? 0) + 1;

        // Logic: Partition modules based on role.
        // We use toLowerCase() and trim() to handle database inconsistencies.
        if (m.uploadedByRole.toLowerCase().trim() == 'admin') {
          admin.add(m);
        } else {
          teacher.add(m);
        }
      }

      // Step 3: Package data into the Stats model
      final stats = ModuleStatsModel(
        totalCount: all.length,
        adminCount: admin.length,
        teacherCount: teacher.length,
        adminModules: admin,
        teacherModules: teacher,
        categoryCounts: catCounts,
      );

      // Step 4: Update the immutable state
      state = state.copyWith(isLoading: false, stats: stats);
    } catch (e) {
      // Logic: Capture any service or parsing errors to show in the UI
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}