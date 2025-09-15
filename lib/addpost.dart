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

  /// Pick image from gallery
  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        print("🖼 Image selected: ${pickedFile.path}");
      } else {
        print("⚠️ No image selected");
      }
    } catch (e) {
      print("❌ Error picking image: $e");
    }
  }

  /// Submit post to backend
 /// Submit post to backend - FIXED VERSION
Future<void> _submitPost() async {
  final personName = _personNameController.text.trim();
  final caption = _captionController.text.trim();

  if (personName.isEmpty || caption.isEmpty || _selectedImage == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please fill all fields and select an image")),
    );
    return;
  }

  // Check image size before uploading
  final fileSize = await _selectedImage!.length();
  final fileSizeMB = fileSize / 1024 / 1024;
  print("Image size: ${fileSizeMB.toStringAsFixed(2)} MB");

  if (fileSizeMB > 10) { // 10MB limit
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Image too large! Please select an image smaller than 10MB")),
    );
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    final userId = await getuserid();
    if (userId == null) {
      throw Exception("User not logged in");
    }

    final result = await ApiService.createPost(
      photo: _selectedImage!,
      personName: personName,
      caption: caption,
      userId: userId,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post created successfully!")),
      );
      Navigator.pop(context);
    }
  } catch (e) {
    print("❌ Error creating post: $e");
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to create post: ${e.toString()}")),
      );
    }
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
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
