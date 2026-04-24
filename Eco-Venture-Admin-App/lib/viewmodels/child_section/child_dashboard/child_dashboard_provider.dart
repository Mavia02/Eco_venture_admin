import 'package:flutter_riverpod/flutter_riverpod.dart';
// Using package imports to ensure proper resolution of the repository instance
import 'package:eco_venture_admin_portal/repositories/admin_firestore_repo.dart';
import 'child_dashboard_state.dart';
import 'child_dashboard_view_model.dart';

/// Logic: Provides a globally accessible ChildDashboardViewModel instance.
/// It uses the singleton instance of AdminFirestoreRepo to interact with the data layer.
final childDashboardProvider =
StateNotifierProvider<ChildDashboardViewModel, ChildDashboardState>((ref) {
  return ChildDashboardViewModel(AdminFirestoreRepo.instance);
});