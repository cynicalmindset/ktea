// import 'package:flutter/material.dart';
// import 'package:ktea/api_service.dart';

// /// 🔹 Expandable Info Box Widget
// class ExpandableInfoBox extends StatefulWidget {
//   final String personName;
//   final String caption;
//   final int redFlags;
//   final int greenFlags;
//   final DateTime createdAt;

//   const ExpandableInfoBox({
//     super.key,
//     required this.personName,
//     required this.caption,
//     required this.redFlags,
//     required this.greenFlags,
//     required this.createdAt,
//   });

//   @override
//   State<ExpandableInfoBox> createState() => _ExpandableInfoBoxState();
// }

// class _ExpandableInfoBoxState extends State<ExpandableInfoBox> {
//   bool expanded = false;

//   String _formatDate(DateTime date) {
//     final now = DateTime.now();
//     final difference = now.difference(date);

//     if (difference.inDays > 0) {
//       return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
//     } else if (difference.inHours > 0) {
//       return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
//     } else if (difference.inMinutes > 0) {
//       return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
//     } else {
//       return 'Just now';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => setState(() => expanded = !expanded),
//       child: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: Colors.grey[850],
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black45,
//               blurRadius: 6,
//               offset: const Offset(0, 3),
//             )
//           ],
//         ),
//         padding: const EdgeInsets.all(12),
//         margin: const EdgeInsets.only(bottom: 12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Text(
//                     widget.personName,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18,
//                       color: Colors.white,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//                 Row(
//                   children: [
//                     Icon(Icons.flag, size: 16, color: Colors.red[300]),
//                     Text(
//                       " ${widget.redFlags}",
//                       style: TextStyle(color: Colors.red[300], fontSize: 12),
//                     ),
//                     const SizedBox(width: 8),
//                     Icon(Icons.flag, size: 16, color: Colors.green[300]),
//                     Text(
//                       " ${widget.greenFlags}",
//                       style: TextStyle(color: Colors.green[300], fontSize: 12),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             const SizedBox(height: 6),
//             Text(
//               widget.caption,
//               style: const TextStyle(fontSize: 15, color: Colors.white),
//               maxLines: expanded ? null : 2,
//               overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Posted ${_formatDate(widget.createdAt)} • Tap to ${expanded ? 'collapse' : 'expand'}',
//               style: TextStyle(
//                 color: Colors.grey[400],
//                 fontSize: 12,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// 🔹 Safe Post Data Model for UI
// class SafePost {
//   final String id;
//   final String imageUrl;
//   final String personName;
//   final String caption;
//   final String uploadedBy;
//   final int upvotes;
//   final int downvotes;
//   final int redFlags;
//   final int greenFlags;
//   final int totalVotes;
//   final bool isActive;
//   final DateTime createdAt;
//   final DateTime updatedAt;

//   SafePost({
//     required this.id,
//     required this.imageUrl,
//     required this.personName,
//     required this.caption,
//     required this.uploadedBy,
//     required this.upvotes,
//     required this.downvotes,
//     required this.redFlags,
//     required this.greenFlags,
//     required this.totalVotes,
//     required this.isActive,
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   factory SafePost.fromJson(Map<String, dynamic> json) {
//     try {
//       // ID
//       String id = '';
//       if (json['_id'] is String) {
//         id = json['_id'];
//       } else if (json['_id'] is Map && json['_id'].containsKey('\$oid')) {
//         id = json['_id']['\$oid'].toString();
//       }

//       // Image
//       String imageUrl = '';
//       if (json['photo'] is Map) {
//         imageUrl = json['photo']['url']?.toString() ?? '';
//       } else if (json['photo'] is String) {
//         imageUrl = json['photo'];
//       }

//       // Uploaded by
//       String uploadedBy = '';
//       if (json['uploadedBy'] is String) {
//         uploadedBy = json['uploadedBy'];
//       } else if (json['uploadedBy'] is Map && json['uploadedBy'].containsKey('\$oid')) {
//         uploadedBy = json['uploadedBy']['\$oid'].toString();
//       }

//       // Votes
//       Map<String, dynamic> votesData = {};
//       if (json['votes'] is Map) {
//         votesData = Map<String, dynamic>.from(json['votes']);
//       }

//       // Dates
//       DateTime createdAt = DateTime.now();
//       DateTime updatedAt = DateTime.now();
//       try {
//         if (json['createdAt'] is String) {
//           createdAt = DateTime.parse(json['createdAt']);
//         } else if (json['createdAt'] is Map && json['createdAt'].containsKey('\$date')) {
//           createdAt = DateTime.parse(json['createdAt']['\$date'].toString());
//         }

//         if (json['updatedAt'] is String) {
//           updatedAt = DateTime.parse(json['updatedAt']);
//         } else if (json['updatedAt'] is Map && json['updatedAt'].containsKey('\$date')) {
//           updatedAt = DateTime.parse(json['updatedAt']['\$date'].toString());
//         }
//       } catch (e) {
//         print('Error parsing dates: $e');
//       }

//       return SafePost(
//         id: id,
//         imageUrl: imageUrl,
//         personName: json['personName']?.toString() ?? 'Unknown',
//         caption: json['caption']?.toString() ?? '',
//         uploadedBy: uploadedBy,
//         upvotes: _safeInt(votesData['upvotes']),
//         downvotes: _safeInt(votesData['downvotes']),
//         redFlags: _safeInt(votesData['redFlags']),
//         greenFlags: _safeInt(votesData['greenFlags']),
//         totalVotes: _safeInt(votesData['totalVotes']),
//         isActive: json['isActive'] ?? true,
//         createdAt: createdAt,
//         updatedAt: updatedAt,
//       );
//     } catch (e) {
//       print('Error parsing SafePost JSON: $e');
//       print('JSON data: $json');
//       rethrow;
//     }
//   }

//   static int _safeInt(dynamic value) {
//     if (value is int) return value;
//     if (value is String) return int.tryParse(value) ?? 0;
//     return 0;
//   }
// }

// /// 🔹 Corrected SafeComment Model
// class SafeComment {
//   final String id;
//   final String postId;
//   final String userId;
//   final String comment;
//   final int upvotes;
//   final int downvotes;
//   final bool isActive;
//   final DateTime createdAt;
//   final DateTime updatedAt;

//   SafeComment({
//     required this.id,
//     required this.postId,
//     required this.userId,
//     required this.comment,
//     required this.upvotes,
//     required this.downvotes,
//     required this.isActive,
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   factory SafeComment.fromJson(Map<String, dynamic> json) {
//     try {
//       String id = json['_id'] is Map && json['_id'].containsKey('\$oid')
//           ? json['_id']['\$oid'].toString()
//           : json['_id']?.toString() ?? '';

//       String postId = json['post'] is Map && json['post'].containsKey('\$oid')
//           ? json['post']['\$oid'].toString()
//           : '';

//       String userId = json['commenter'] is Map && json['commenter'].containsKey('\$oid')
//           ? json['commenter']['\$oid'].toString()
//           : 'Anonymous';

//       DateTime createdAt = DateTime.now();
//       DateTime updatedAt = DateTime.now();
//       try {
//         if (json['createdAt'] is Map && json['createdAt'].containsKey('\$date')) {
//           createdAt = DateTime.parse(json['createdAt']['\$date'].toString());
//         }
//         if (json['updatedAt'] is Map && json['updatedAt'].containsKey('\$date')) {
//           updatedAt = DateTime.parse(json['updatedAt']['\$date'].toString());
//         }
//       } catch (e) {
//         print('Error parsing comment dates: $e');
//       }

//       return SafeComment(
//         id: id,
//         postId: postId,
//         userId: userId,
//         comment: json['content']?.toString() ?? '',
//         upvotes: _safeInt(json['upvotes']),
//         downvotes: _safeInt(json['downvotes']),
//         isActive: json['isActive'] ?? true,
//         createdAt: createdAt,
//         updatedAt: updatedAt,
//       );
//     } catch (e) {
//       print('Error parsing SafeComment JSON: $e');
//       print('JSON data: $json');
//       return SafeComment(
//         id: '',
//         postId: '',
//         userId: 'Anonymous',
//         comment: json['content']?.toString() ?? 'Error loading comment',
//         upvotes: 0,
//         downvotes: 0,
//         isActive: true,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       );
//     }
//   }

//   static int _safeInt(dynamic value) {
//     if (value is int) return value;
//     if (value is String) return int.tryParse(value) ?? 0;
//     return 0;
//   }
// }

// /// 🔹 Expandable Comments Section
// class ExpandableComments extends StatefulWidget {
//   final String postId;
//   final String currentUserId;

//   const ExpandableComments({
//     super.key,
//     required this.postId,
//     required this.currentUserId,
//   });

//   @override
//   State<ExpandableComments> createState() => _ExpandableCommentsState();
// }

// class _ExpandableCommentsState extends State<ExpandableComments> {
//   bool expanded = false;
//   List<SafeComment> comments = [];
//   bool isLoadingComments = false;
//   bool isSubmittingComment = false;
//   final TextEditingController _commentController = TextEditingController();
//   final FocusNode _commentFocusNode = FocusNode();

//   @override
//   void dispose() {
//     _commentController.dispose();
//     _commentFocusNode.dispose();
//     super.dispose();
//   }

//   Future<void> _loadComments() async {
//     if (isLoadingComments) return;

//     setState(() => isLoadingComments = true);

//     try {
//       final fetchedComments = await ApiService.getComments(widget.postId);

//       setState(() {
//         comments = fetchedComments
//             .map((commentData) => SafeComment.fromJson(commentData))
//             .where((comment) => comment.isActive) // filter inactive
//             .toList();
//         isLoadingComments = false;
//       });
//     } catch (e) {
//       print('Error loading comments: $e');
//       setState(() => isLoadingComments = false);
//     }
//   }

//   Future<void> _submitComment() async {
//     final comment = _commentController.text.trim();
//     if (comment.isEmpty) return;

//     setState(() => isSubmittingComment = true);

//     try {
//       await ApiService.createComment(
//         postId: widget.postId,
//         userId: widget.currentUserId,
//         comment: comment,
//       );

//       _commentController.clear();
//       _commentFocusNode.unfocus();
//       setState(() => isSubmittingComment = false);
//       await _loadComments();
//     } catch (e) {
//       print('Error submitting comment: $e');
//       setState(() => isSubmittingComment = false);
//     }
//   }

//   String _formatCommentDate(DateTime date) {
//     final diff = DateTime.now().difference(date);
//     if (diff.inDays > 0) return '${diff.inDays}d ago';
//     if (diff.inHours > 0) return '${diff.inHours}h ago';
//     if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
//     return 'now';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.only(bottom: 20),
//       decoration: BoxDecoration(
//         color: Colors.grey[850],
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ListTile(
//             title: Text(
//               expanded ? "Hide gossips" : "View gossips",
//               style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
//             ),
//             trailing: Icon(
//               expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
//               color: Colors.white,
//             ),
//             onTap: () {
//               setState(() => expanded = !expanded);
//               if (expanded && comments.isEmpty) _loadComments();
//             },
//           ),
//           if (expanded) ...[
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               child: Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[700],
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         controller: _commentController,
//                         focusNode: _commentFocusNode,
//                         style: const TextStyle(color: Colors.white),
//                         decoration: const InputDecoration(
//                           hintText: "Add a gossip...",
//                           hintStyle: TextStyle(color: Colors.grey),
//                           border: InputBorder.none,
//                         ),
//                         maxLines: null,
//                         textInputAction: TextInputAction.send,
//                         onSubmitted: (_) => _submitComment(),
//                       ),
//                     ),
//                     isSubmittingComment
//                         ? const SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               color: Colors.blueAccent,
//                             ),
//                           )
//                         : IconButton(
//                             onPressed: _submitComment,
//                             icon: const Icon(Icons.send, color: Colors.blueAccent),
//                           ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 8),
//             Padding(
//               padding: const EdgeInsets.all(12),
//               child: isLoadingComments
//                   ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
//                   : comments.isEmpty
//                       ? const Text(
//                           "No gossips yet. Be the first to comment!",
//                           style: TextStyle(color: Colors.grey),
//                         )
//                       : Column(
//                           children: comments.map((comment) {
//                             return Container(
//                               width: double.infinity,
//                               margin: const EdgeInsets.only(bottom: 8),
//                               padding: const EdgeInsets.all(10),
//                               decoration: BoxDecoration(
//                                 color: Colors.grey[700],
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Expanded(
//                                         child: RichText(
//                                           text: TextSpan(
//                                             style: const TextStyle(color: Colors.white, fontSize: 14),
//                                             children: [
//                                               TextSpan(
//                                                 text: "${comment.userId}: ",
//                                                 style: const TextStyle(fontWeight: FontWeight.bold),
//                                               ),
//                                               TextSpan(text: comment.comment),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                       Text(
//                                         _formatCommentDate(comment.createdAt),
//                                         style: TextStyle(color: Colors.grey[400], fontSize: 11),
//                                       ),
//                                     ],
//                                   ),
//                                   if (comment.upvotes > 0 || comment.downvotes > 0)
//                                     Padding(
//                                       padding: const EdgeInsets.only(top: 4),
//                                       child: Row(
//                                         children: [
//                                           Icon(Icons.thumb_up, size: 16, color: Colors.green[300]),
//                                           Text(" ${comment.upvotes}", style: TextStyle(color: Colors.green[300], fontSize: 12)),
//                                           const SizedBox(width: 12),
//                                           Icon(Icons.thumb_down, size: 16, color: Colors.red[300]),
//                                           Text(" ${comment.downvotes}", style: TextStyle(color: Colors.red[300], fontSize: 12)),
//                                         ],
//                                       ),
//                                     ),
//                                 ],
//                               ),
//                             );
//                           }).toList(),
//                         ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }

// /// 🔹 Home Page
// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   List<SafePost> posts = [];
//   bool isLoading = true;
//   String? errorMessage;
//   String currentUserId = '';
//   bool isInitialized = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeUser();
//   }

//   Future<void> _initializeUser() async {
//     try {
//       final response = await ApiService.registerUser();
//       String userId = '';
//       if (response is Map && response.containsKey('user')) {
//         final user = response['user'];
//         if (user is Map) {
//           if (user['_id'] is String) userId = user['_id'];
//           else if (user['_id'] is Map && user['_id'].containsKey('\$oid')) userId = user['_id']['\$oid'].toString();
//         }
//       } else if (response is Map && response.containsKey('_id')) {
//         if (response['_id'] is String) userId = response['_id'];
//         else if (response['_id'] is Map && response['_id'].containsKey('\$oid')) userId = response['_id']['\$oid'].toString();
//       }

//       if (userId.isEmpty) userId = 'user_${DateTime.now().millisecondsSinceEpoch}';

//       setState(() {
//         currentUserId = userId;
//         isInitialized = true;
//       });

//       _loadPosts();
//     } catch (e) {
//       setState(() {
//         errorMessage = 'Failed to initialize user: $e';
//         isInitialized = true;
//       });
//     }
//   }

//   Future<void> _loadPosts() async {
//     setState(() {
//       isLoading = true;
//       errorMessage = null;
//     });

//     try {
//       final fetchedPosts = await ApiService.getPosts();
//       setState(() {
//         posts = fetchedPosts.map((data) => SafePost.fromJson(data)).where((p) => p.isActive).toList();
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         errorMessage = 'Failed to load posts: $e';
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!isInitialized) {
//       return const Scaffold(
//         backgroundColor: Colors.black,
//         body: Center(
//           child: CircularProgressIndicator(color: Colors.blueAccent),
//         ),
//       );
//     }

//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: const Text('Posts'),
//         backgroundColor: Colors.grey[900],
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
//           : errorMessage != null
//               ? Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red)))
//               : RefreshIndicator(
//                   onRefresh: _loadPosts,
//                   child: ListView.builder(
//                     padding: const EdgeInsets.all(12),
//                     itemCount: posts.length,
//                     itemBuilder: (context, index) {
//                       final post = posts[index];
//                       return Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           ExpandableInfoBox(
//                             personName: post.personName,
//                             caption: post.caption,
//                             redFlags: post.redFlags,
//                             greenFlags: post.greenFlags,
//                             createdAt: post.createdAt,
//                           ),
//                           if (post.imageUrl.isNotEmpty)
//                             ClipRRect(
//                               borderRadius: BorderRadius.circular(16),
//                               child: Image.network(post.imageUrl, fit: BoxFit.cover),
//                             ),
//                           ExpandableComments(
//                             postId: post.id,
//                             currentUserId: currentUserId,
//                           ),
//                         ],
//                       );
//                     },
//                   ),
//                 ),
//     );
//   }
// }
