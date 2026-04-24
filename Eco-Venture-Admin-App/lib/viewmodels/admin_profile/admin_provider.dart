import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/admin_firestore_repo.dart';
import 'admin_profile_state.dart';
import 'admin_view_model.dart';

//  Provides a globally accessible AdminViewModel instance
final adminProfileProviderNew =
StateNotifierProvider<AdminViewModel, AdminProfileState>((ref) {
  return AdminViewModel(AdminFirestoreRepo.instance);
});
