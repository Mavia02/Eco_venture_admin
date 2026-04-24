import 'package:eco_venture_admin_portal/models/admin_model.dart';


class AuthState {
  // Email login state
  final bool isEmailLoading;
  final String? emailError;


  // Common fields
  final AdminModel? admin;

  AuthState({
    this.isEmailLoading = false,
    this.emailError,
    this.admin,
  });

  AuthState copyWith({
    bool? isEmailLoading,
    String? emailError,
    AdminModel? admin,
  }) {
    return AuthState(
      isEmailLoading: isEmailLoading ?? this.isEmailLoading,
      emailError: emailError ?? this.emailError,
      admin: admin??this.admin,
    );
  }

  factory AuthState.initial() => AuthState();
}
