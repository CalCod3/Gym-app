// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_print

import 'package:wod_book/services/moderation_service.dart';
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

  // Instance of the OpenAI Moderation service
  final OpenAIModerationService _moderationService = OpenAIModerationService();

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
                ? null
                : () async {
                    print('Form submitted...');
                    if (_formKey.currentState!.validate()) {
                      print('Form validated...');
                      setState(() {
                        _isLoading = true;
                      });

                      try {
                        print('Moderating content...');
                        bool isContentFlagged = await _moderationService
                            .checkContent(_contentController.text);
                        print('Moderation result: $isContentFlagged');

                        if (isContentFlagged) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'The content of your post is flagged for moderation.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        print('Creating post...');
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

                        await postProvider.addPost(newPost);
                        print('Post created successfully.');

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Post created successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      } catch (e) {
                        print('Error occurred: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      } finally {
                        setState(() {
                          _isLoading = false;
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
                      ? NetworkImage(currentUserProfileImageUrl)
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
