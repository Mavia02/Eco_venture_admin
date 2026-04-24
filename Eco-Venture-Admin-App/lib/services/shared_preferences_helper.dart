import 'package:shared_preferences/shared_preferences.dart';


class SharedPreferencesHelper {
  SharedPreferencesHelper._();
  static final SharedPreferencesHelper instance = SharedPreferencesHelper._();

  static const String adminIdKey = 'admin_id';
  static const String adminNameKey = 'admin_name';
  static const String adminEmailKey = 'admin_email';
  static const String adminImgUrlKey = 'admin_img_url';

  // ===== Save =====
  Future<bool> saveAdminId(String adminId) async {
    final pref = await SharedPreferences.getInstance();
    return pref.setString(adminIdKey, adminId);
  }

  Future<bool> saveAdminName(String adminName) async {
    final pref = await SharedPreferences.getInstance();
    return pref.setString(adminNameKey, adminName);
  }

  Future<bool> saveAdminEmail(String adminEmail) async {
    final pref = await SharedPreferences.getInstance();
    return pref.setString(adminEmailKey, adminEmail);
  }

  Future<bool> saveAdminImgUrl(String imgUrl) async {
    final pref = await SharedPreferences.getInstance();
    return pref.setString(adminImgUrlKey, imgUrl);
  }

  // ===== Get =====
  Future<String?> getAdminId() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(adminIdKey);
  }

  Future<String?> getAdminName() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(adminNameKey);
  }

  Future<String?> getAdminEmail() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(adminEmailKey);
  }

  Future<String?> getAdminImgUrl() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(adminImgUrlKey);
  }

  // ===== Clear =====
  Future<void> clearAll() async {
    final pref = await SharedPreferences.getInstance();
    await pref.remove(adminIdKey);
    await pref.remove(adminNameKey);
    await pref.remove(adminEmailKey);
    await pref.remove(adminImgUrlKey);
  }
}
