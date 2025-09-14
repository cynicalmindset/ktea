import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // ⚠️ Update if Ngrok URL changes
  static const String baseUrl = "https://1863cbc9686b.ngrok-free.app/api";

  // Common headers
  static Map<String, String> get _headers => {
    "Content-Type": "application/json",
  };

  // ======================
  // AUTH ENDPOINTS
  // ======================

  /// Register/Create a new user
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

  /// Login user with credentials
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
  // POSTS ENDPOINTS
  // ======================

  /// Create a new post with image, person name and caption
  static Future<Map<String, dynamic>> createPost({
    required File imageFile,
    required String personName,
    required String caption,
    required String uploadedBy,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/posts/create"),
      );

      // Add fields
      request.fields['personName'] = personName;
      request.fields['caption'] = caption;
      request.fields['uploadedBy'] = uploadedBy;

      // Add image file
      request.files.add(
        await http.MultipartFile.fromPath('photo', imageFile.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("Create Post Status: ${response.statusCode}");
      print("Create Post Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final res = jsonDecode(response.body);
        return res.containsKey("data") ? res["data"] : res;
      } else {
        throw Exception("Failed to create post: ${response.body}");
      }
    } catch (e) {
      print("Create Post Exception: $e");
      rethrow;
    }
  }

  /// Get all posts
  static Future<List<Map<String, dynamic>>> getAllPosts() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/posts"),
        headers: _headers,
      );

      print("Get Posts Status: ${response.statusCode}");
      print("Get Posts Body: ${response.body}");

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        if (res is List) {
          return List<Map<String, dynamic>>.from(res);
        } else if (res.containsKey("data") && res["data"] is List) {
          return List<Map<String, dynamic>>.from(res["data"]);
        } else {
          throw Exception("Unexpected response format for posts");
        }
      } else {
        throw Exception("Failed to get posts: ${response.body}");
      }
    } catch (e) {
      print("Get Posts Exception: $e");
      rethrow;
    }
  }

  // ======================
  // COMMENTS ENDPOINTS
  // ======================

  /// Create a comment on a post
  static Future<Map<String, dynamic>> createComment({
    required String postId,
    required String userId,
    required String comment,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/comments/create"),
        headers: _headers,
        body: jsonEncode({
          "postId": postId,
          "userId": userId,
          "comment": comment,
        }),
      );

      print("Create Comment Status: ${response.statusCode}");
      print("Create Comment Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final res = jsonDecode(response.body);
        return res.containsKey("data") ? res["data"] : res;
      } else {
        throw Exception("Failed to create comment: ${response.body}");
      }
    } catch (e) {
      print("Create Comment Exception: $e");
      rethrow;
    }
  }

  /// Get comments for a specific post
  static Future<List<Map<String, dynamic>>> getComments(String postId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/comments/post/$postId"),
        headers: _headers,
      );

      print("Get Comments Status: ${response.statusCode}");
      print("Get Comments Body: ${response.body}");

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        if (res is List) {
          return List<Map<String, dynamic>>.from(res);
        } else if (res.containsKey("data") && res["data"] is List) {
          return List<Map<String, dynamic>>.from(res["data"]);
        } else {
          throw Exception("Unexpected response format for comments");
        }
      } else {
        throw Exception("Failed to get comments: ${response.body}");
      }
    } catch (e) {
      print("Get Comments Exception: $e");
      rethrow;
    }
  }

  /// Vote on a comment (upvote/downvote)
  static Future<Map<String, dynamic>> voteOnComment({
    required String commentId,
    required String userId,
    required String voteType, // "upvote" or "downvote"
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/comments/vote"),
        headers: _headers,
        body: jsonEncode({
          "commentId": commentId,
          "userId": userId,
          "voteType": voteType,
        }),
      );

      print("Vote Comment Status: ${response.statusCode}");
      print("Vote Comment Body: ${response.body}");

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        return res.containsKey("data") ? res["data"] : res;
      } else {
        throw Exception("Failed to vote on comment: ${response.body}");
      }
    } catch (e) {
      print("Vote Comment Exception: $e");
      rethrow;
    }
  }

  // ======================
  // VOTING/FLAGS ENDPOINTS
  // ======================

  /// Flag a person in a post (red flag/green flag)
  static Future<Map<String, dynamic>> flagPerson({
    required String postId,
    required String userId,
    required String flagType, // "redFlag" or "greenFlag"
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/votes/post"),
        headers: _headers,
        body: jsonEncode({
          "postId": postId,
          "userId": userId,
          "flagType": flagType,
        }),
      );

      print("Flag Person Status: ${response.statusCode}");
      print("Flag Person Body: ${response.body}");

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        return res.containsKey("data") ? res["data"] : res;
      } else {
        throw Exception("Failed to flag person: ${response.body}");
      }
    } catch (e) {
      print("Flag Person Exception: $e");
      rethrow;
    }
  }

  /// Get flags/votes for a specific post
  static Future<Map<String, dynamic>> getPersonFlags(String postId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/votes/post/$postId"),
        headers: _headers,
      );

      print("Get Person Flags Status: ${response.statusCode}");
      print("Get Person Flags Body: ${response.body}");

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        return res.containsKey("data") ? res["data"] : res;
      } else {
        throw Exception("Failed to get person flags: ${response.body}");
      }
    } catch (e) {
      print("Get Person Flags Exception: $e");
      rethrow;
    }
  }

  /// Get safest people (highest green flags/lowest red flags)
  static Future<List<Map<String, dynamic>>> getSafestPeople() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/votes/safest"),
        headers: _headers,
      );

      print("Get Safest People Status: ${response.statusCode}");
      print("Get Safest People Body: ${response.body}");

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        if (res is List) {
          return List<Map<String, dynamic>>.from(res);
        } else if (res.containsKey("data") && res["data"] is List) {
          return List<Map<String, dynamic>>.from(res["data"]);
        } else {
          throw Exception("Unexpected response format for safest people");
        }
      } else {
        throw Exception("Failed to get safest people: ${response.body}");
      }
    } catch (e) {
      print("Get Safest People Exception: $e");
      rethrow;
    }
  }

  // ======================
  // UTILITY METHODS
  // ======================

  /// Generic GET request
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl$endpoint"),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("GET request failed: ${response.body}");
      }
    } catch (e) {
      print("GET Exception: $e");
      rethrow;
    }
  }

  /// Generic POST request
  static Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl$endpoint"),
        headers: _headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception("POST request failed: ${response.body}");
      }
    } catch (e) {
      print("POST Exception: $e");
      rethrow;
    }
  }
}

// ======================
// DATA MODELS
// ======================

class User {
  final String id;
  final String username;
  final String password;
  final bool isActive;
  final int commentsPosted;
  final int totalUpvotes;
  final int totalDownvotes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int userCount;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.isActive,
    required this.commentsPosted,
    required this.totalUpvotes,
    required this.totalDownvotes,
    required this.createdAt,
    required this.updatedAt,
    required this.userCount,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id']['\$oid'] ?? json['_id'],
      username: json['username'],
      password: json['password'],
      isActive: json['isActive'] ?? true,
      commentsPosted: json['commentsPosted'] ?? 0,
      totalUpvotes: json['totalUpvotes'] ?? 0,
      totalDownvotes: json['totalDownvotes'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']['\$date'] ?? json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']['\$date'] ?? json['updatedAt']),
      userCount: json['userCount'] ?? 0,
    );
  }
}

class Post {
  final String id;
  final PhotoData photo;
  final String personName;
  final String caption;
  final String uploadedBy;
  final VotesData votes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Post({
    required this.id,
    required this.photo,
    required this.personName,
    required this.caption,
    required this.uploadedBy,
    required this.votes,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['_id']['\$oid'] ?? json['_id'],
      photo: PhotoData.fromJson(json['photo']),
      personName: json['personName'],
      caption: json['caption'],
      uploadedBy: json['uploadedBy']['\$oid'] ?? json['uploadedBy'],
      votes: VotesData.fromJson(json['votes']),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']['\$date'] ?? json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']['\$date'] ?? json['updatedAt']),
    );
  }
}

class PhotoData {
  final String url;
  final String publicId;

  PhotoData({required this.url, required this.publicId});

  factory PhotoData.fromJson(Map<String, dynamic> json) {
    return PhotoData(
      url: json['url'],
      publicId: json['public_id'],
    );
  }
}

class VotesData {
  final int upvotes;
  final int downvotes;
  final int redFlags;
  final int greenFlags;
  final int totalVotes;

  VotesData({
    required this.upvotes,
    required this.downvotes,
    required this.redFlags,
    required this.greenFlags,
    required this.totalVotes,
  });

  factory VotesData.fromJson(Map<String, dynamic> json) {
    return VotesData(
      upvotes: json['upvotes'] ?? 0,
      downvotes: json['downvotes'] ?? 0,
      redFlags: json['redFlags'] ?? 0,
      greenFlags: json['greenFlags'] ?? 0,
      totalVotes: json['totalVotes'] ?? 0,
    );
  }
}