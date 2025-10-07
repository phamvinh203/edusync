import 'package:shared_preferences/shared_preferences.dart';
import 'package:edusync/models/auth_model.dart';

/// Service to handle user session data storage for notifications
class UserSessionService {
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';

  /// Store user data after successful login
  static Future<void> storeUserData(AuthUser user) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_userIdKey, user.id);
    await prefs.setString(_userRoleKey, user.role);
    await prefs.setString(_userNameKey, user.username);
    await prefs.setString(_userEmailKey, user.email);
  }

  /// Get current user ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// Get current user role
  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  /// Get current user name
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  /// Get current user email
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  /// Clear user data on logout
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_userIdKey);
    await prefs.remove(_userRoleKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
  }

  /// Check if user is teacher
  static Future<bool> isTeacher() async {
    final role = await getUserRole();
    return role?.toLowerCase() == 'teacher';
  }

  /// Check if user is student
  static Future<bool> isStudent() async {
    final role = await getUserRole();
    return role?.toLowerCase() == 'student';
  }
}
