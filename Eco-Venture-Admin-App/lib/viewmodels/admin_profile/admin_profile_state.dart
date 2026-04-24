import 'package:eco_venture_admin_portal/models/admin_model.dart';

class AdminProfileState {
  final bool isLoading;
  final String? error;
  final AdminModel? adminProfile;

  const AdminProfileState({
    required this.isLoading,
    this.error,
    this.adminProfile,
  });

  factory AdminProfileState.initial() {
    return const AdminProfileState(
      isLoading: false,
      error: null,
      adminProfile: null,
    );
  }

  AdminProfileState copyWith({
    bool? isLoading,
    String? error,
    AdminModel? adminProfile,
  }) {
    return AdminProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      adminProfile: adminProfile ?? this.adminProfile,
    );
  }
}
