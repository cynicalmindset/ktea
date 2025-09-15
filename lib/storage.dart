import 'package:shared_preferences/shared_preferences.dart';

/// Save login data (userId, username, password)
Future<void> saveLoginData(String userId, String username, String password) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('userId', userId);
  await prefs.setString('username', username);
  await prefs.setString('password', password); // new
}

/// Check if logged in
Future<bool> isLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('userId') != null;
}

/// Logout (clear all)
Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('userId');
  await prefs.remove('username');
  await prefs.remove('password'); // new
}

/// Get username
Future<String?> getUsername() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('username');
}

/// Get password
Future<String?> getPassword() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('password'); // new
}

/// Get userid
Future<String?> getuserid() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('userId'); // new
}

/// Get all user data
Future<Map<String, String>?> getUserData() async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('userId');
  final username = prefs.getString('username');
  final password = prefs.getString('password'); // new

  if (userId != null && username != null && password != null) {
    return {
      "userId": userId,
      "username": username,
      "password": password, // new
    };
  }
  return null;
}
