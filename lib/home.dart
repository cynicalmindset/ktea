import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ktea/addpost.dart';
import 'package:ktea/api_service.dart';
import 'package:ktea/userpage.dart';
import '../models/safe_post.dart';
import '../widgets/expandable_info_box.dart';
import '../widgets/expandable_comments.dart';
//import '../widgets/custom_toggle_appbar.dart';

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
  int selectedTabIndex = 0; // Add this for tab management

  void _handleTabChange(int index) {
    setState(() {
      selectedTabIndex = index;
    });
    // Handle different tab actions here
    switch (index) {
      case 0: // Home
        _loadPosts();
        break;
      case 1: // Profile
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const UserProfilePage(),
          ),
        );
        break;
      case 2: // Chat
        print('Chat tab selected');
        break;
    }
  }

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
      // 🔹 Removed AppBar
      floatingActionButton: selectedTabIndex == 0 ? FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddPostPage(),
            ),
          );
          if (result == true) {
            _loadPosts();
          }
        },
        backgroundColor: Colors.white,
        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),
      ) : null,
      body: _buildCurrentTabContent(),
    );
  }

  Widget _buildCurrentTabContent() {
    switch (selectedTabIndex) {
      case 0: 
        return _buildHomeContent();
      case 1: 
        return _buildProfileContent();
      case 2: 
        return _buildChatContent();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
    }
    
    if (errorMessage != null) {
      return Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red)));
    }
    
    return RefreshIndicator(
      onRefresh: _loadPosts,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: posts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 20),
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
                onFlagUpdate: _loadPosts,
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
    );
  }

  Widget _buildProfileContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person,
            size: 80,
            color: Colors.white,
          ),
          SizedBox(height: 16),
          Text(
            'Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Profile content coming soon!',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat,
            size: 80,
            color: Colors.white,
          ),
          SizedBox(height: 16),
          Text(
            'Chat',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Chat functionality coming soon!',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
