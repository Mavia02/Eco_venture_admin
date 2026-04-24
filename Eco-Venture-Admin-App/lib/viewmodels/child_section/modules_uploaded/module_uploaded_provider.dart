import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eco_venture_admin_portal/repositories/module_uploaded_repo.dart';
import 'modules_uploaded_view_model.dart';
import 'module_uploaded_state.dart';

/// Logic: Provides a globally accessible instance of the ModulesUploadedViewModel.
/// It injects the singleton instance of ModuleRepo to maintain the data flow.
final modulesUploadedProvider =
StateNotifierProvider<ModulesUploadedViewModel, ModuleUploadedState>((ref) {
  return ModulesUploadedViewModel(ModuleRepo.instance);
});