// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/user_provider.dart';
import '../../model/post_model.dart';

class CommentCreateScreen extends StatefulWidget {
  final int postId;

  const CommentCreateScreen({super.key, required this.postId});

  @override
  // ignore: library_private_types_in_public_api
  _CommentCreateScreenState createState() => _CommentCreateScreenState();
}

class _CommentCreateScreenState extends State<CommentCreateScreen> {
  final _commentController = TextEditingController();
  bool _isSubmitting = false;
  int? currentUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if the user is logged in before building the widget
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    currentUserId = userProvider.userId;
    if (currentUserId == null) {
      // If user is not logged in, display a snackbar and return to the previous screen
      Future.microtask(() {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Comment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Enter your comment',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),
            const SizedBox(height: 16.0),
            _isSubmitting
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submitComment,
                    child: const Text('Submit'),
                  ),
            const SizedBox(height: 16.0),
            Expanded(
              child: Consumer<PostProvider>(
                builder: (context, postProvider, child) {
                  final post = postProvider.getPostById(widget.postId);
                  if (post == null) {
                    return const Center(child: Text('Post not found'));
                  }
                  return ListView.builder(
                    itemCount: post.comments.length,
                    itemBuilder: (context, index) {
                      final comment = post.comments[index];
                      return ListTile(
                        title: Text(comment.content),
                        subtitle: Text('User ID: ${comment.userId}'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitComment() async {
    final commentContent = _commentController.text.trim();

    if (commentContent.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment cannot be empty')),
      );
      return;
    }

    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final navigator = Navigator.of(context);

    try {
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      final newComment = Comment(
        id: 0,
        content: commentContent,
        postId: widget.postId,
        userId: currentUserId!,
      );

      await postProvider.addComment(widget.postId, newComment);

      await _fetchComments();
      navigator.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add comment: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _fetchComments() async {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    await postProvider.fetchPosts();
  }
}
