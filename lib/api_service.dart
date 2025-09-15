import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  static const String baseUrl = "https://kitea-production.up.railway.app/api";

  static Map<String, String> get _headers => {
        "Content-Type": "application/json",
      };

  // ========================================================
  // AUTH ENDPOINTS
  // ========================================================
 static MediaType _getMediaType(File file) {
    String extension = file.path.toLowerCase().split('.').last;
    
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'webp':
        return MediaType('image', 'webp');
      default:
        return MediaType('image', 'jpeg'); // Default fallback
    }
  }
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
      print("🚀 Starting createPost...");
      print("📸 Photo path: ${photo.path}");
      print("👤 Person: $personName");
      print("📝 Caption: $caption");
      print("🆔 User ID: $userId");

      // Validate file exists and is readable
      if (!await photo.exists()) {
        throw Exception("Image file does not exist");
      }

      final fileSize = await photo.length();
      print("📏 File size: ${fileSize} bytes (${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB)");

      if (fileSize > 50 * 1024 * 1024) { // 50MB limit
        throw Exception("Image file too large. Maximum size is 50MB");
      }

      // Create multipart request
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/posts/create'));
      
      print("🌐 Request URL: $baseUrl/posts/create");

      // Add text fields
      request.fields['personName'] = personName;
      request.fields['caption'] = caption;
      request.fields['userId'] = userId;

      print("📝 Added fields: ${request.fields}");

      // Add image file with correct MIME type
      MediaType mediaType = _getMediaType(photo);
      print("🖼 Media type: ${mediaType.mimeType}");

      var multipartFile = await http.MultipartFile.fromPath(
        'photo',
        photo.path,
        contentType: mediaType,
      );

      request.files.add(multipartFile);
      print("✅ Added photo file");

      // Send request with longer timeout and progress tracking
      print("📡 Sending request...");
      
      http.StreamedResponse streamedResponse;
      try {
        streamedResponse = await request.send().timeout(
          const Duration(minutes: 5), // Increased to 5 minutes
          onTimeout: () {
            print("⏰ Request timed out after 5 minutes");
            throw Exception("Request timed out. Please check your internet connection and try again.");
          },
        );
      } catch (e) {
        print("🚨 Network error during request: $e");
        throw Exception("Network error: ${e.toString()}");
      }

      print("📨 Response received - Status: ${streamedResponse.statusCode}");
      
      // Read response
      final response = await http.Response.fromStream(streamedResponse);
      print("📄 Response body length: ${response.body.length}");
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Success response");
        try {
          final Map<String, dynamic> jsonResponse = json.decode(response.body);
          print("🎉 Post created successfully!");
          return jsonResponse;
        } catch (e) {
          print("❌ JSON parsing error: $e");
          print("📄 Raw response: ${response.body}");
          throw Exception("Failed to parse server response");
        }
      } else {
        print("❌ Server error - Status: ${response.statusCode}");
        print("📄 Error response: ${response.body}");
        
        // Try to parse error response
        try {
          final errorData = json.decode(response.body);
          throw Exception("Server error: ${errorData['message'] ?? 'Unknown error'}");
        } catch (_) {
          throw Exception("Server error (${response.statusCode}): ${response.body}");
        }
      }

    } on SocketException catch (e) {
      print("🌐 Network connectivity error: $e");
      throw Exception("No internet connection. Please check your network and try again.");
    } on TimeoutException catch (e) {
      print("⏰ Timeout error: $e");
      throw Exception("Request timed out. Please try again with a smaller image or check your internet connection.");
    } on FormatException catch (e) {
      print("📄 JSON format error: $e");
      throw Exception("Invalid server response format");
    } catch (e) {
      print("❌ Unexpected error: $e");
      throw Exception("Failed to create post: ${e.toString()}");
    }
  }

  /// Test server connectivity
  static Future<bool> testConnectivity() async {
    try {
      print("🔍 Testing server connectivity...");
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));
      
      print("🌐 Connectivity test - Status: ${response.statusCode}");
      return response.statusCode == 200;
    } catch (e) {
      print("❌ Connectivity test failed: $e");
      return false;
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

  /// Get all posts
static Future<List<dynamic>> getAllPosts() async {
  try {
    final response = await http.get(
      Uri.parse("$baseUrl/posts"),
      headers: _headers,
    );

    print("Get All Posts Status: ${response.statusCode}");
    print("Get All Posts Body: ${response.body}");

    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);
      return res.containsKey("data") ? res["data"] : res;
    } else {
      throw Exception("Failed to fetch posts: ${response.body}");
    }
  } catch (e) {
    print("Get All Posts Exception: $e");
    rethrow;
  }
}


}
