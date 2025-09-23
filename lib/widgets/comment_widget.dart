import 'package:flutter/material.dart';
import 'package:ktea/api_service.dart';
import '../models/safe_comment.dart';

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
      // Add more detailed logging
      print('=== COMMENT VOTE DEBUG ===');
      print('Comment ID: ${widget.comment.id}');
      print('User ID: ${widget.currentUserId}');
      print('Vote: $vote');
      print('Current upvotes: $currentUpvotes');
      print('Current downvotes: $currentDownvotes');
      
      final response = await ApiService.voteOnComment(
        widget.comment.id, 
        widget.currentUserId, 
        vote
      );
      print('Vote API response: $response');

      // Check if the API call was successful
      if (response != null && response.containsKey('success')) {
        if (response['success'] == true) {
          // Only update if API was successful
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

          // Refresh comments to get server counts
          await Future.delayed(const Duration(milliseconds: 300));
          widget.onVoteUpdate();
        } else {
          throw Exception(response['message'] ?? 'Vote failed');
        }
      } else {
        print('Unexpected API response format: $response');
        throw Exception('Unexpected server response');
      }

    } catch (e) {
      print('Error voting on comment: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
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