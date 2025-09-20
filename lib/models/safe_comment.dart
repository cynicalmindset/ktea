/// 🔹 Safe Comment Model
class SafeComment {
  final String id;
  final String postId;
  final String userId;
  final String comment;
  final int upvotes;
  final int downvotes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  SafeComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.comment,
    required this.upvotes,
    required this.downvotes,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SafeComment.fromJson(Map<String, dynamic> json) {
    try {
      String id = json['commentId'] ?? '';
      String postId = json['postId'] ?? '';

      final commenter = json['commenter'] ?? {};
      String userId = commenter['_id'] ?? 'Anonymous';
      String username = commenter['username'] ?? 'Anonymous';

      DateTime createdAt = DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now();
      DateTime updatedAt = DateTime.now(); // no updatedAt field provided here

      return SafeComment(
        id: id,
        postId: postId,
        userId: username, // optionally show username instead of id
        comment: json['content'] ?? '',
        upvotes: _safeInt(json['upvotes']),
        downvotes: _safeInt(json['downvotes']),
        isActive: true,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    } catch (e) {
      print('Error parsing SafeComment JSON: $e');
      // Return fallback comment to avoid crash
      return SafeComment(
        id: '',
        postId: '',
        userId: 'Anonymous',
        comment: json['content']?.toString() ?? 'Error loading comment',
        upvotes: 0,
        downvotes: 0,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  static int _safeInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}