import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/auth_repo.dart';
import 'auth_state.dart';
import 'auth_view_model.dart';

final authRepoProvider = Provider<AuthRepo>((ref) {
  return AuthRepo.instance;
});

final authViewModelProvider =
StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  final repo = ref.read(authRepoProvider);
  return AuthViewModel(repo);
});
