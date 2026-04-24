import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../repositories/admin_treasure_hunt_repository.dart';
import '../../../services/firebase_database_service.dart';
import 'admin_treasure_hun_state.dart';
import 'admin_treasure_hunt_view_model.dart';


// 1. Service (Reuse existing singleton logic if available, or define here)
final firebaseDatabaseServiceProvider = Provider((ref) => FirebaseDatabaseService());

// 2. Repository
final adminTreasureHuntRepositoryProvider = Provider<AdminTreasureHuntRepository>((ref) {
  return AdminTreasureHuntRepository(ref.watch(firebaseDatabaseServiceProvider));
});

// 3. ViewModel
final adminTreasureHuntViewModelProvider = StateNotifierProvider<AdminTreasureHuntViewModel, AdminTreasureHuntState>((ref) {
  return AdminTreasureHuntViewModel(ref.watch(adminTreasureHuntRepositoryProvider));
});