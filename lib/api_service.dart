import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://kitea-production.up.railway.app/api";

  static Map<String, String> get _headers => {
        "Content-Type": "application/json",
      };

  // ========================================================
  // AUTH ENDPOINTS
  // ========================================================

  /// 🟢 Register/Create a new user
  static Future<Map<String, dynamic>> registerUser() async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/create-user"),
        headers: _headers,
        body: jsonEncode({}),
      );

      print("Register Status: ${response.statusCode}");
      print("Register Body: ${response.body}");

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        return res.containsKey("data") ? res["data"] : res;
      } else {
        throw Exception("Failed to register: ${response.body}");
      }
    } catch (e) {
      print("Register Exception: $e");
      rethrow;
    }
  }

  /// 🟢 Login user
  static Future<Map<String, dynamic>> loginUser(
      String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: _headers,
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );

      print("Login Status: ${response.statusCode}");
      print("Login Body: ${response.body}");

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        return res.containsKey("data") ? res["data"] : res;
      } else {
        throw Exception("Failed to login: ${response.body}");
      }
    } catch (e) {
      print("Login Exception: $e");
      rethrow;
    }
  }

  // ========================================================
  // POST ENDPOINTS
  // ========================================================

  /// 🟢 Create a new post
   static Future<Map<String, dynamic>> createPost({
    required File photo,
    required String personName,
    required String caption,
    required String userId,
  }) async {
    try {
      var request =
          http.MultipartRequest("POST", Uri.parse("$baseUrl/posts/create"));

      // Attach photo file
      request.files.add(await http.MultipartFile.fromPath("photo", photo.path));

      // Add other fields
      request.fields["personName"] = personName;
      request.fields["caption"] = caption;
      request.fields["userId"] = userId;

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("Create Post Status: ${response.statusCode}");
      print("Create Post Body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to create post: ${response.body}");
      }
    } catch (e) {
      print("Create Post Exception: $e");
      rethrow;
    }
  }

  /// 🟢 Get all posts
  static Future<List<dynamic>> getAllPosts() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/posts"));

      print("Get Posts Status: ${response.statusCode}");
      print("Get Posts Body: ${response.body}");

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        return res.containsKey("data") ? res["data"] : res;
      } else {
        throw Exception("Failed to fetch posts: ${response.body}");
      }
    } catch (e) {
      print("Get Posts Exception: $e");
      rethrow;
    }
  }

  /// 🟢 Delete a post
  static Future<Map<String, dynamic>> deletePost(String postId) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/posts/delete"),
        headers: _headers,
        body: jsonEncode({"postId": postId}),
      );

      print("Delete Post Status: ${response.statusCode}");
      print("Delete Post Body: ${response.body}");

      return jsonDecode(response.body);
    } catch (e) {
      print("Delete Post Exception: $e");
      rethrow;
    }
  }

  // ========================================================
  // COMMENT ENDPOINTS
  // ========================================================

  /// 🟢 Create a comment
  static Future<Map<String, dynamic>> createComment(
      String postId, String userId, String text) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/comments/create"),
        headers: _headers,
        body: jsonEncode({
          "postId": postId,
          "userId": userId,
          "text": text,
        }),
      );

      print("Create Comment Status: ${response.statusCode}");
      print("Create Comment Body: ${response.body}");

      return jsonDecode(response.body);
    } catch (e) {
      print("Create Comment Exception: $e");
      rethrow;
    }
  }

  /// 🟢 Get comments for a post
  static Future<List<dynamic>> getComments(String postId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/comments/post/$postId"),
        headers: _headers,
      );

      print("Get Comments Status: ${response.statusCode}");
      print("Get Comments Body: ${response.body}");

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        return res.containsKey("data") ? res["data"] : res;
      } else {
        throw Exception("Failed to fetch comments: ${response.body}");
      }
    } catch (e) {
      print("Get Comments Exception: $e");
      rethrow;
    }
  }

  /// 🟢 Vote on a comment
  static Future<Map<String, dynamic>> voteOnComment(
      String commentId, String userId, int vote) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/comments/vote"),
        headers: _headers,
        body: jsonEncode({
          "commentId": commentId,
          "userId": userId,
          "vote": vote, // 1 = upvote, -1 = downvote
        }),
      );

      print("Vote Comment Status: ${response.statusCode}");
      print("Vote Comment Body: ${response.body}");

      return jsonDecode(response.body);
    } catch (e) {
      print("Vote Comment Exception: $e");
      rethrow;
    }
  }

  /// 🟢 Delete a comment
  static Future<Map<String, dynamic>> deleteComment(String commentId) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/comments/delete"),
        headers: _headers,
        body: jsonEncode({"commentId": commentId}),
      );

      print("Delete Comment Status: ${response.statusCode}");
      print("Delete Comment Body: ${response.body}");

      return jsonDecode(response.body);
    } catch (e) {
      print("Delete Comment Exception: $e");
      rethrow;
    }
  }

  // ========================================================
  // FLAG / VOTES ENDPOINTS
  // ========================================================

  /// 🟢 Flag a person (red/green flag)
  static Future<Map<String, dynamic>> flagPerson(
      String postId, String userId, String flagType) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/votes/post"),
        headers: _headers,
        body: jsonEncode({
          "postId": postId,
          "userId": userId,
          "flagType": flagType, // e.g., "red" or "green"
        }),
      );

      print("Flag Person Status: ${response.statusCode}");
      print("Flag Person Body: ${response.body}");

      return jsonDecode(response.body);
    } catch (e) {
      print("Flag Person Exception: $e");
      rethrow;
    }
  }

  /// 🟢 Get person flags
  static Future<Map<String, dynamic>> getPersonFlags(String postId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/votes/post/$postId"),
        headers: _headers,
      );

      print("Get Person Flags Status: ${response.statusCode}");
      print("Get Person Flags Body: ${response.body}");

      return jsonDecode(response.body);
    } catch (e) {
      print("Get Person Flags Exception: $e");
      rethrow;
    }
  }

  /// 🟢 Get safest people
  static Future<List<dynamic>> getSafestPeople() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/votes/safest"),
        headers: _headers,
      );

      print("Get Safest People Status: ${response.statusCode}");
      print("Get Safest People Body: ${response.body}");

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        return res.containsKey("data") ? res["data"] : res;
      } else {
        throw Exception("Failed to fetch safest people: ${response.body}");
      }
    } catch (e) {
      print("Get Safest People Exception: $e");
      rethrow;
    }
  }
}
