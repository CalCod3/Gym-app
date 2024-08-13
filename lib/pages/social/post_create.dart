// screens/new_post_screen.dart
// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/user_provider.dart';
import '../../model/post_model.dart';

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NewPostScreenState createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUserId = userProvider.authProvider?.userId;
    final currentUserName = userProvider.name;
    final currentUserProfileImageUrl = userProvider.profileImageUrl;

    print(currentUserId);
    print(currentUserName);
    print(currentUserProfileImageUrl);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
        actions: [
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final newPost = Post(
                  id: DateTime.now().millisecondsSinceEpoch,
                  title: _titleController.text,
                  content: _contentController.text,
                  userId: currentUserId!,
                  comments: [],
                  userProfileImageUrl: '',
                  userName: '',
                );
                Provider.of<PostProvider>(context, listen: false)
                    .addPost(newPost);
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Tweet',
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
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(currentUserProfileImageUrl!),
                ),
                title: Text(currentUserName!),
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
