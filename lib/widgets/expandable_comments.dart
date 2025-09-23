import 'package:flutter/material.dart';
import 'package:ktea/api_service.dart';
import '../models/safe_comment.dart';
import 'comment_widget.dart';

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
          AnimatedSize(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            child: ConstrainedBox(
              constraints: expanded
                  ? const BoxConstraints()
                  : const BoxConstraints(maxHeight: 0),
              child: Column(
                children: [
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
                                "Start the gossiping!",
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}