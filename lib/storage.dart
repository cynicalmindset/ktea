import 'package:shared_preferences/shared_preferences.dart';

// Save login data
Future<void> saveLoginData(String token, String username) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', token);
  await prefs.setString('username', username);
}

// Check if logged in
Future<bool> isLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token') != null;
}

// Logout
Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('token');
  await prefs.remove('username');
}
