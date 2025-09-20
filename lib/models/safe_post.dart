/// 🔹 Safe Post Data Model for UI
class SafePost {
  final String id;
  final String imageUrl;
  final String personName;
  final String caption;
  final String uploadedBy;
  final int upvotes;
  final int downvotes;
  final int redFlags;
  final int greenFlags;
  final int totalVotes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  SafePost({
    required this.id,
    required this.imageUrl,
    required this.personName,
    required this.caption,
    required this.uploadedBy,
    required this.upvotes,
    required this.downvotes,
    required this.redFlags,
    required this.greenFlags,
    required this.totalVotes,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SafePost.fromJson(Map<String, dynamic> json) {
    try {
      // ID
      String id = '';
      if (json['_id'] is String) {
        id = json['_id'];
      } else if (json['_id'] is Map && json['_id'].containsKey('\$oid')) {
        id = json['_id']['\$oid'].toString();
      }

      // Image
      String imageUrl = '';
      if (json['photo'] is Map) {
        imageUrl = json['photo']['url']?.toString() ?? '';
      } else if (json['photo'] is String) {
        imageUrl = json['photo'];
      }

      // Uploaded by
      String uploadedBy = '';
      if (json['uploadedBy'] is String) {
        uploadedBy = json['uploadedBy'];
      } else if (json['uploadedBy'] is Map && json['uploadedBy'].containsKey('\$oid')) {
        uploadedBy = json['uploadedBy']['\$oid'].toString();
      }

      // Votes
      Map<String, dynamic> votesData = {};
      if (json['votes'] is Map) {
        votesData = Map<String, dynamic>.from(json['votes']);
      }

      // Dates
      DateTime createdAt = DateTime.now();
      DateTime updatedAt = DateTime.now();
      try {
        if (json['createdAt'] is String) {
          createdAt = DateTime.parse(json['createdAt']);
        } else if (json['createdAt'] is Map && json['createdAt'].containsKey('\$date')) {
          createdAt = DateTime.parse(json['createdAt']['\$date'].toString());
        }

        if (json['updatedAt'] is String) {
          updatedAt = DateTime.parse(json['updatedAt']);
        } else if (json['updatedAt'] is Map && json['updatedAt'].containsKey('\$date')) {
          updatedAt = DateTime.parse(json['updatedAt']['\$date'].toString());
        }
      } catch (e) {
        print('Error parsing dates: $e');
      }

      return SafePost(
        id: id,
        imageUrl: imageUrl,
        personName: json['personName']?.toString() ?? 'Unknown',
        caption: json['caption']?.toString() ?? '',
        uploadedBy: uploadedBy,
        upvotes: _safeInt(votesData['upvotes']),
        downvotes: _safeInt(votesData['downvotes']),
        redFlags: _safeInt(votesData['redFlags']),
        greenFlags: _safeInt(votesData['greenFlags']),
        totalVotes: _safeInt(votesData['totalVotes']),
        isActive: json['isActive'] ?? true,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    } catch (e) {
      print('Error parsing SafePost JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  static int _safeInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}