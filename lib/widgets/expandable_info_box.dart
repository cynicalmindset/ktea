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
    final response = await ApiService.flagPerson(
      postId: widget.postId,
      voteType: flagType == "red" ? "redFlag" : "greenFlag",
      userId: widget.currentUserId,
    );

    print('Flag response: $response');
    await Future.delayed(const Duration(milliseconds: 300));
    await _updateFlagCounts();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(flagType == "red" ? "Red flag added!" : "Green flag added!"),
          backgroundColor: flagType == "red" ? Colors.red[700] : Colors.green[700],
        ),
      );
    }

    widget.onFlagUpdate();
  } catch (e) {
    print('Error flagging person: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add flag. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    if (mounted) setState(() => isFlagging = false);
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