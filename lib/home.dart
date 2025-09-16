import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ktea/api_service.dart';

/// 🔹 Expandable Info Box Widget with Flag Functionality
class ExpandableInfoBox extends StatefulWidget {
  final String postId;
  final String personName;
  final String caption;
  final int redFlags;
  final int greenFlags;
  final DateTime createdAt;
  final String currentUserId;
  final VoidCallback onFlagUpdate; // Callback to refresh post data

  const ExpandableInfoBox({
    super.key,
    required this.postId,
    required this.personName,
    required this.caption,
    required this.redFlags,
    required this.greenFlags,
    required this.createdAt,
    required this.currentUserId,
    required this.onFlagUpdate,
  });

  @override
  State<ExpandableInfoBox> createState() => _ExpandableInfoBoxState();
}

class _ExpandableInfoBoxState extends State<ExpandableInfoBox> {
  bool expanded = false;
  bool isFlagging = false;
  int currentRedFlags = 0;
  int currentGreenFlags = 0;

  @override
  void initState() {
    super.initState();
    currentRedFlags = widget.redFlags;
    currentGreenFlags = widget.greenFlags;
  }

  @override
  void didUpdateWidget(ExpandableInfoBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.redFlags != widget.redFlags || oldWidget.greenFlags != widget.greenFlags) {
      currentRedFlags = widget.redFlags;
      currentGreenFlags = widget.greenFlags;
    }
  }

  Future<void> _updateFlagCounts() async {
    try {
      final flagData = await ApiService.getPersonFlags(widget.postId);
      print('Flag data received: $flagData');
      
      if (flagData.containsKey('votes')) {
        final votes = flagData['votes'];
        setState(() {
          currentRedFlags = votes['redFlags'] ?? currentRedFlags;
          currentGreenFlags = votes['greenFlags'] ?? currentGreenFlags;
        });
      }
    } catch (e) {
      print('Error fetching updated flags: $e');
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _flagPerson(String flagType) async {
    if (isFlagging) return;

    setState(() => isFlagging = true);

    try {
      final response = await ApiService.flagPerson(widget.postId, widget.currentUserId, flagType);
      print('Flag response: $response'); // Debug log
      
      // Wait a moment then fetch updated flag counts
      await Future.delayed(const Duration(milliseconds: 300));
      await _updateFlagCounts();
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${flagType == "red" ? "Red" : "Green"} flag added!'),
            backgroundColor: flagType == "red" ? Colors.red[700] : Colors.green[700],
            duration: const Duration(seconds: 2),
          ),
        );
      }
      
      // Also notify parent for any other updates needed
      widget.onFlagUpdate();
    } catch (e) {
      print('Error flagging person: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add flag. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isFlagging = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => expanded = !expanded),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.personName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _flagPerson("red"),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red[900]?.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.flag, size: 16, color: Colors.red[300]),
                            Text(
                              " $currentRedFlags",
                              style: TextStyle(color: Colors.red[300], fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _flagPerson("green"),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green[900]?.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.flag, size: 16, color: Colors.green[300]),
                            Text(
                              " $currentGreenFlags",
                              style: TextStyle(color: Colors.green[300], fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isFlagging) ...[
                      const SizedBox(width: 8),
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              widget.caption,
              style: const TextStyle(fontSize: 15, color: Colors.white),
              maxLines: expanded ? null : 2,
              overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              'Posted ${_formatDate(widget.createdAt)} • Tap to ${expanded ? 'collapse' : 'expand'}',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

/// 🔹 Corrected SafeComment Model
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

/// 🔹 Comment Widget with Voting
class CommentWidget extends StatefulWidget {
  final SafeComment comment;
  final String currentUserId;
  final VoidCallback onVoteUpdate;

  const CommentWidget({
    super.key,
    required this.comment,
    required this.currentUserId,
    required this.onVoteUpdate,
  });

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  bool isVoting = false;
  int currentUpvotes = 0;
  int currentDownvotes = 0;

  @override
  void initState() {
    super.initState();
    currentUpvotes = widget.comment.upvotes;
    currentDownvotes = widget.comment.downvotes;
  }

  @override
  void didUpdateWidget(CommentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.comment.upvotes != widget.comment.upvotes || 
        oldWidget.comment.downvotes != widget.comment.downvotes) {
      currentUpvotes = widget.comment.upvotes;
      currentDownvotes = widget.comment.downvotes;
    }
  }

  String _formatCommentDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'now';
  }

  Future<void> _voteOnComment(int vote) async {
    if (isVoting) return;

    setState(() => isVoting = true);

    try {
      final response = await ApiService.voteOnComment(
        widget.comment.id, 
        widget.currentUserId, 
        vote
      );
      print('Vote response: $response'); // Debug log

      // Optimistically update the local counts immediately for better UX
      setState(() {
        if (vote == 1) {
          currentUpvotes++;
        } else if (vote == -1) {
          currentDownvotes++;
        }
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${vote == 1 ? "Upvoted" : "Downvoted"} comment!'),
            backgroundColor: vote == 1 ? Colors.green[700] : Colors.red[700],
            duration: const Duration(seconds: 1),
          ),
        );
      }

      // Wait a bit then refresh comments to get server counts
      await Future.delayed(const Duration(milliseconds: 500));
      widget.onVoteUpdate();
    } catch (e) {
      print('Error voting on comment: $e');
      // Revert optimistic update on error
      setState(() {
        if (vote == 1) {
          currentUpvotes--;
        } else if (vote == -1) {
          currentDownvotes--;
        }
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to vote. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isVoting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[700],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    children: [
                      TextSpan(
                        text: "${widget.comment.userId}: ",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: widget.comment.comment),
                    ],
                  ),
                ),
              ),
              Text(
                _formatCommentDate(widget.comment.createdAt),
                style: TextStyle(color: Colors.grey[400], fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Upvote button
              GestureDetector(
                onTap: isVoting ? null : () => _voteOnComment(1),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[900]?.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.thumb_up,
                        size: 16,
                        color: isVoting ? Colors.grey : Colors.green[300],
                      ),
                      Text(
                        " $currentUpvotes",
                        style: TextStyle(
                          color: isVoting ? Colors.grey : Colors.green[300],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Downvote button
              GestureDetector(
                onTap: isVoting ? null : () => _voteOnComment(-1),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red[900]?.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.thumb_down,
                        size: 16,
                        color: isVoting ? Colors.grey : Colors.red[300],
                      ),
                      Text(
                        " $currentDownvotes",
                        style: TextStyle(
                          color: isVoting ? Colors.grey : Colors.red[300],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isVoting) ...[
                const SizedBox(width: 12),
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// 🔹 Expandable Comments Section
class ExpandableComments extends StatefulWidget {
  final String postId;
  final String currentUserId;

  const ExpandableComments({
    super.key,
    required this.postId,
    required this.currentUserId,
  });

  @override
  State<ExpandableComments> createState() => _ExpandableCommentsState();
}

class _ExpandableCommentsState extends State<ExpandableComments> {
  bool expanded = false;
  List<SafeComment> comments = [];
  bool isLoadingComments = false;
  bool isSubmittingComment = false;
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    if (isLoadingComments) return;

    setState(() => isLoadingComments = true);

    try {
      final fetchedComments = await ApiService.getComments(widget.postId);

      setState(() {
        comments = fetchedComments
            .map((commentData) => SafeComment.fromJson(commentData))
            .where((comment) => comment.isActive) // filter inactive
            .toList();
        isLoadingComments = false;
      });
    } catch (e) {
      print('Error loading comments: $e');
      setState(() => isLoadingComments = false);
    }
  }

  Future<void> _submitComment() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) return;

    setState(() => isSubmittingComment = true);

    try {
      await ApiService.createComment(
        widget.postId,
        widget.currentUserId,
        comment,
      );

      _commentController.clear();
      _commentFocusNode.unfocus();
      setState(() => isSubmittingComment = false);
      await _loadComments();
    } catch (e) {
      print('Error submitting comment: $e');
      setState(() => isSubmittingComment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              expanded ? "Hide gossips" : "View gossips",
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            trailing: Icon(
              expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.white,
            ),
            onTap: () {
              setState(() => expanded = !expanded);
              if (expanded && comments.isEmpty) _loadComments();
            },
          ),
          if (expanded) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        focusNode: _commentFocusNode,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: "Add a gossip...",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _submitComment(),
                      ),
                    ),
                    isSubmittingComment
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.blueAccent,
                            ),
                          )
                        : IconButton(
                            onPressed: _submitComment,
                            icon: const Icon(Icons.send, color: Colors.blueAccent),
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(12),
              child: isLoadingComments
                  ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
                  : comments.isEmpty
                      ? const Text(
                          "No gossips yet. Be the first to comment!",
                          style: TextStyle(color: Colors.grey),
                        )
                      : Column(
                          children: comments.map((comment) {
                            return CommentWidget(
                              comment: comment,
                              currentUserId: widget.currentUserId,
                              onVoteUpdate: _loadComments,
                            );
                          }).toList(),
                        ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 🔹 Home Page
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<SafePost> posts = [];
  bool isLoading = true;
  String? errorMessage;
  String currentUserId = '';
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    try {
      final response = await ApiService.registerUser();
      String userId = '';
      if (response is Map && response.containsKey('user')) {
        final user = response['user'];
        if (user is Map) {
          if (user['_id'] is String) userId = user['_id'];
          else if (user['_id'] is Map && user['_id'].containsKey('\$oid')) userId = user['_id']['\$oid'].toString();
        }
      } else if (response is Map && response.containsKey('_id')) {
        if (response['_id'] is String) userId = response['_id'];
        else if (response['_id'] is Map && response['_id'].containsKey('\$oid')) userId = response['_id']['\$oid'].toString();
      }

      if (userId.isEmpty) userId = 'user_${DateTime.now().millisecondsSinceEpoch}';

      setState(() {
        currentUserId = userId;
        isInitialized = true;
      });

      _loadPosts();
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to initialize user: $e';
        isInitialized = true;
      });
    }
  }

  Future<void> _loadPosts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final fetchedPosts = await ApiService.getPosts();

      final mappedPosts = fetchedPosts.map((post) {
        return {
          '_id': post['postId'] ?? '',
          'personName': post['personName'] ?? 'Unknown',
          'caption': post['caption'] ?? '',
          'photo': post['photoUrl'] ?? '',
          'uploadedBy': post['uploadedBy'] ?? '',
          'votes': post['votes'] ?? {},
          'createdAt': post['createdAt'] ?? DateTime.now().toIso8601String(),
          'updatedAt': post['createdAt'] ?? DateTime.now().toIso8601String(),
          'isActive': true,
        };
      }).toList();

      setState(() {
        posts = mappedPosts.map((data) => SafePost.fromJson(data)).where((p) => p.isActive).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load posts: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.blueAccent),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Posts'),
        backgroundColor: Colors.grey[900],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : errorMessage != null
              ? Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red)))
              : RefreshIndicator(
                  onRefresh: _loadPosts,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: posts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 20), // gap between posts
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (post.imageUrl.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: double.infinity,
                                constraints: const BoxConstraints(
                                  maxHeight: 400,
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: post.imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[800],
                                    child: const Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    color: Colors.grey[800],
                                    child: const Icon(Icons.error, color: Colors.redAccent),
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),
                          ExpandableInfoBox(
                            postId: post.id,
                            personName: post.personName,
                            caption: post.caption,
                            redFlags: post.redFlags,
                            greenFlags: post.greenFlags,
                            createdAt: post.createdAt,
                            currentUserId: currentUserId,
                            onFlagUpdate: _loadPosts, // Refresh posts when flags are updated
                          ),
                          const SizedBox(height: 12),
                          ExpandableComments(
                            postId: post.id,
                            currentUserId: currentUserId,
                          ),
                        ],
                      );
                    },
                  ),
                ),
    );
  }
}