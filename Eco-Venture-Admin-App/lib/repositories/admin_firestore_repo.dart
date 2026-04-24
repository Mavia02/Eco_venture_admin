import 'package:eco_venture_admin_portal/models/admin_model.dart';
import 'package:eco_venture_admin_portal/services/admin_firestore_service.dart';

class AdminFirestoreRepo {
  AdminFirestoreRepo._();

  static final AdminFirestoreRepo instance = AdminFirestoreRepo._();

  /// Logic: Fetches all child users.
  Future<List<Map<String, dynamic>>> getAllChildren() async {
    return await AdminFirestoreService.getInstance.getAllChildren();
  }

  /// Logic: Fetches all teacher users.
  Future<List<Map<String, dynamic>>> getAllTeachers() async {
    return await AdminFirestoreService.getInstance.getAllTeachers();
  }

  // --- 🔒 Admin Profile Methods Preserved ---

  Future<AdminModel?> addAdminProfile({
    required String aid,
    required String email,
  }) async {
    return await AdminFirestoreService.getInstance.createBasicAdminProfile(
      aid: aid,
      email: email,
    );
  }

  Future<bool> updateAdminName(String aid, String name) async {
    return await AdminFirestoreService.getInstance.updateAdminName(aid, name);
  }

  Future<bool> updateAdminImageUrl(String aid, String imageUrl) async {
    return await AdminFirestoreService.getInstance.updateAdminImage(aid, imageUrl);
  }

  Future<bool> updateAdminEmail(String aid, String email) async {
    return await AdminFirestoreService.getInstance.updateAdminEmail(aid, email);
  }

  Future<AdminModel?> getAdminProfile(String aid) async {
    return await AdminFirestoreService.getInstance.getAdminProfile(aid);
  }

  Future<void> deleteAdminData(String aid) async {
    await AdminFirestoreService.getInstance.deleteAdminData(aid);
  }
}
