import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ⚠️ Update if Ngrok URL changes
  static const String baseUrl = "https://1863cbc9686b.ngrok-free.app/api";

  // ======================
  // REGISTER USER
  // ======================
  static Future<Map<String, dynamic>> registerUser() async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/create-user"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({}),
      );

      print("Register Status: ${response.statusCode}");
      print("Register Body: ${response.body}");

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        if (res.containsKey("username") && res.containsKey("password")) {
          return res;
        } else if (res.containsKey("data")) {
          return res["data"];
        } else {
          throw Exception("Register failed: unexpected response format");
        }
      } else {
        throw Exception("Failed to register: ${response.body}");
      }
    } catch (e) {
      print("Register Exception: $e");
      rethrow;
    }
  }

  // ======================
  // LOGIN USER
  // ======================
  static Future<Map<String, dynamic>> loginUser(
      String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );

      print("Login Status: ${response.statusCode}");
      print("Login Body: ${response.body}");

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        if (res.containsKey("data")) {
          return res["data"];
        }
        return res;
      } else {
        throw Exception("Failed to login: ${response.body}");
      }
    } catch (e) {
      print("Login Exception: $e");
      rethrow;
    }
  }
}


