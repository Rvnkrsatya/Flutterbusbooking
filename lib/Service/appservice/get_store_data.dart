import 'package:shared_preferences/shared_preferences.dart';

class GetStoreData {
  static Future<void> storeUserData({
    required String userId,   // userId
    required String Id,   // _id (Mongo DB ID)
    required String name,
    required String email,
    required String authToken,
    String? phone,
    String? role,
    String? deviceId,
    String? createdAt,
    String? updatedAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('userId', userId);
    await prefs.setString('_id', Id);
    await prefs.setString('user_fullName', name);
    await prefs.setString('user_email', email);
    await prefs.setString('token', authToken);
    await prefs.setBool('user_isLoggedIn', true);

    if (phone != null) await prefs.setString('user_phone', phone);
    if (role != null) await prefs.setString('user_role', role);
    if (deviceId != null) await prefs.setString('user_deviceId', deviceId);
    if (createdAt != null) await prefs.setString('user_createdAt', createdAt);
    if (updatedAt != null) await prefs.setString('user_updatedAt', updatedAt);
  }
}
