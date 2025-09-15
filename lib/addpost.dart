import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'api_service.dart';
import 'storage.dart'; 

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final TextEditingController _personNameController = TextEditingController();
  final TextEditingController _captionController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitPost() async {
    final personName = _personNameController.text.trim();
    final caption = _captionController.text.trim();

    if (personName.isEmpty || caption.isEmpty || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields and pick an image")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // ✅ Get userId from storage
      final userId = await getuserid();

      if (userId == null) {
        throw Exception("User not logged in");
      }

      final res = await ApiService.createPost(
          photo: _selectedImage!,
          personName: personName,
          caption: caption,
          userId: userId,
        );

      print("✅ Post created: $res");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post created successfully!")),
      );

      Navigator.pop(context); // Go back to Home
    } catch (e) {
      print("❌ Post creation failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Post")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _personNameController,
                decoration: const InputDecoration(labelText: "Person Name"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _captionController,
                decoration: const InputDecoration(labelText: "Caption"),
                maxLines: 3,
              ),
              const SizedBox(height: 12),

              _selectedImage != null
                  ? Image.file(_selectedImage!, height: 150)
                  : const Text("No image selected"),

              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text("Pick Image"),
              ),

              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitPost,
                      child: const Text("Submit Post"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
