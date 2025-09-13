import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ⚠️ Update if Ngrok URL changes
  static const String baseUrl = "https://810002fd175b.ngrok-free.app/api";

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

  // ======================
  // FETCH POSTS
  // ======================
  static Future<List<dynamic>> fetchPosts() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/posts"));

      print("Fetch Posts Status: ${response.statusCode}");
      print("Fetch Posts Body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to fetch posts: ${response.body}");
      }
    } catch (e) {
      print("Fetch Posts Exception: $e");
      rethrow;
    }
  }

  // ======================
  // UPLOAD POST
  // ======================
  static Future<Map<String, dynamic>> uploadPost(
      String imageUrl, String context, String username) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/posts"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "image": imageUrl,
          "context": context,
          "username": username,
        }),
      );

      print("Upload Post Status: ${response.statusCode}");
      print("Upload Post Body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to upload post: ${response.body}");
      }
    } catch (e) {
      print("Upload Post Exception: $e");
      rethrow;
    }
  }

  // ======================
  // UPVOTE POST
  // ======================
  static Future<Map<String, dynamic>> upvotePost(String postId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/posts/$postId/vote"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"upvote": true}),
      );

      print("Upvote Status: ${response.statusCode}");
      print("Upvote Body: ${response.body}");

      return jsonDecode(response.body);
    } catch (e) {
      print("Upvote Exception: $e");
      rethrow;
    }
  }

  // ======================
  // DOWNVOTE POST
  // ======================
  static Future<Map<String, dynamic>> downvotePost(String postId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/posts/$postId/vote"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"upvote": false}),
      );

      print("Downvote Status: ${response.statusCode}");
      print("Downvote Body: ${response.body}");

      return jsonDecode(response.body);
    } catch (e) {
      print("Downvote Exception: $e");
      rethrow;
    }
  }

  // ======================
  // ADD COMMENT
  // ======================
  static Future<Map<String, dynamic>> addComment(
      String postId, String comment) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/posts/$postId/comment"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"comment": comment}),
      );

      print("Comment Status: ${response.statusCode}");
      print("Comment Body: ${response.body}");

      return jsonDecode(response.body);
    } catch (e) {
      print("Comment Exception: $e");
      rethrow;
    }
  }
}
