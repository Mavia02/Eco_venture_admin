import 'package:eco_venture_admin_portal/services/auth_services.dart';

import '../models/admin_model.dart';

class AuthRepo {
  AuthRepo._();

  static final AuthRepo instance = AuthRepo._();

  Future<AdminModel?> loginAdmin(String email, String password) async {
    try {
      return await AuthServices.instance.login(email, password);
    } catch (e) {
       print(e.toString());
      rethrow;
    }
  }
  Future<void> forgotPassword(String email) async {
    await AuthServices.instance.forgotPassword(email);
  }

  Future<void> signOutAdmin() async {
    await AuthServices.instance.signOut();
  }
  Future<void> deleteAccount()async{
    await AuthServices.instance.deleteAccount();
  }
}
