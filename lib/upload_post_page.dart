import 'package:flutter/material.dart';
import 'api_service.dart';

class UploadPostPage extends StatefulWidget {
  const UploadPostPage({super.key});

  @override
  State<UploadPostPage> createState() => _UploadPostPageState();
}

class _UploadPostPageState extends State<UploadPostPage> {
  final TextEditingController imageController = TextEditingController();
  final TextEditingController contextController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  bool _loading = false;

  void _uploadPost() async {
    if (imageController.text.isEmpty ||
        contextController.text.isEmpty ||
        usernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required!")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await ApiService.uploadPost(
        imageController.text,
        contextController.text,
        usernameController.text,
      );

      Navigator.pop(context, true); // return true to refresh feed
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Post")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: imageController,
              decoration: const InputDecoration(
                labelText: "Image URL",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contextController,
              decoration: const InputDecoration(
                labelText: "Context / Description",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _uploadPost,
                    icon: const Icon(Icons.upload),
                    label: const Text("Upload"),
                  ),
          ],
        ),
      ),
    );
  }
}
