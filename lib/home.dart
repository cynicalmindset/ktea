import 'package:flutter/material.dart';
import 'api_service.dart';
import 'upload_post_page.dart'; // new page for uploading

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<dynamic>> _posts;

  @override
  void initState() {
    super.initState();
    _posts = ApiService.fetchPosts();
  }

  void _refreshPosts() {
    setState(() {
      _posts = ApiService.fetchPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Campus Feed"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _posts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No posts yet 😶"));
          }

          final posts = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async => _refreshPosts(),
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                final postId = post["_id"] ?? "";
                final username = post["username"] ?? "Anonymous";
                final contextText = post["context"] ?? "";
                final imageUrl = post["image"] ?? "";
                final votes = post["votes"] ?? 0;

                return Card(
                  margin: const EdgeInsets.all(12),
                  elevation: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imageUrl.isNotEmpty)
                        Stack(
                          alignment: Alignment.bottomLeft,
                          children: [
                            Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 200,
                              errorBuilder: (ctx, error, stack) =>
                                  const Icon(Icons.broken_image, size: 80),
                            ),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [Colors.black54, Colors.transparent],
                                ),
                              ),
                              child: Text(
                                username,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(contextText,
                            style: const TextStyle(fontSize: 16)),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.thumb_up_alt_outlined),
                            onPressed: () async {
                              await ApiService.upvotePost(postId);
                              _refreshPosts();
                            },
                          ),
                          Text(votes.toString()),
                          IconButton(
                            icon: const Icon(Icons.thumb_down_alt_outlined),
                            onPressed: () async {
                              await ApiService.downvotePost(postId);
                              _refreshPosts();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.comment_outlined),
                            onPressed: () => _showCommentDialog(postId),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),

      // ✅ Floating Add Button
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final uploaded = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UploadPostPage()),
          );

          if (uploaded == true) {
            _refreshPosts();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCommentDialog(String postId) {
    final TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Comment"),
        content: TextField(
          controller: commentController,
          decoration: const InputDecoration(hintText: "Enter your comment..."),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Post"),
            onPressed: () async {
              if (commentController.text.isNotEmpty) {
                await ApiService.addComment(postId, commentController.text);
                _refreshPosts();
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
