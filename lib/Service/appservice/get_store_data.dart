import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetStoreData {
  static Future<void> storeUserData({
    required String userId,   // userId
    required String Id,       // _id (Mongo DB ID)
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

  // ✅ Method to get and print all stored user data
  static Future<void> printUserData() async {
    final prefs = await SharedPreferences.getInstance();

    final userId = prefs.getString('userId') ?? '';
    final mongoId = prefs.getString('_id') ?? '';
    final name = prefs.getString('user_fullName') ?? '';
    final email = prefs.getString('user_email') ?? '';
    final token = prefs.getString('token') ?? '';
    final isLoggedIn = prefs.getBool('user_isLoggedIn') ?? false;
    final phone = prefs.getString('user_phone') ?? '';
    final role = prefs.getString('user_role') ?? '';
    final deviceId = prefs.getString('user_deviceId') ?? '';
    final createdAt = prefs.getString('user_createdAt') ?? '';
    final updatedAt = prefs.getString('user_updatedAt') ?? '';

    debugPrint('===== User Data from SharedPreferences =====');
    debugPrint('userId: $userId');
    debugPrint('_id: $mongoId');
    debugPrint('Name: $name');
    debugPrint('Email: $email');
    debugPrint('Token: $token');
    debugPrint('Is Logged In: $isLoggedIn');
    debugPrint('Phone: $phone');
    debugPrint('Role: $role');
    debugPrint('DeviceId: $deviceId');
    debugPrint('Created At: $createdAt');
    debugPrint('Updated At: $updatedAt');
    debugPrint('============================================');
  }
}
