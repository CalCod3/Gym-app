// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/user_provider.dart';
import '../../model/post_model.dart';

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  _NewPostScreenState createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isLoading = false; // Loading state for async behavior

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final postProvider = Provider.of<PostProvider>(context, listen: false);

    final currentUserId = userProvider.authProvider?.userId;
    final currentUserName = userProvider.name;
    final currentUserProfileImageUrl = userProvider.profileImageUrl;

    if (currentUserId == null || currentUserName == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('New Post'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
        actions: [
          TextButton(
            onPressed: _isLoading
                ? null // Disable button when loading
                : () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isLoading = true; // Start loading
                      });

                      final newPost = Post(
                        id: DateTime.now().millisecondsSinceEpoch,
                        title: _titleController.text,
                        content: _contentController.text,
                        userId: currentUserId,
                        comments: [],
                        userProfileImageUrl: currentUserProfileImageUrl ??
                            'assets/images/avatar.png',
                        userName: currentUserName,
                      );

                      try {
                        await postProvider.addPost(newPost);
                        // Success: Show success message and navigate back
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Post created successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      } catch (error) {
                        // Error: Show error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to create post: $error'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } finally {
                        setState(() {
                          _isLoading = false; // End loading
                        });
                      }
                    }
                  },
            child: const Text(
              'Send',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_isLoading)
                const LinearProgressIndicator(), // Show progress indicator during post creation
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: currentUserProfileImageUrl != null
                      ? NetworkImage(currentUserProfileImageUrl!)
                      : null, // If URL is null, we will use the icon
                  child: currentUserProfileImageUrl == null
                      ? Icon(
                          Icons
                              .account_circle_outlined, // The icon to display when the image is null
                          size: 30.0, // Adjust the size as needed
                          color: Colors.grey, // Customize the color as needed
                        )
                      : null, // If the image is not null, we don't display the icon
                ),
                title: Text(currentUserName),
              ),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Title',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: 'What\'s happening?',
                ),
                maxLines: 10,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some content';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
