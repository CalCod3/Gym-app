// screens/post_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/post_model.dart';
import '../../providers/post_provider.dart';
import '../../providers/user_provider.dart';

class PostDetailScreen extends StatelessWidget {
  final Post post;

  const PostDetailScreen({required this.post, super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUserId = userProvider.authProvider?.userId;
    final currentUserProfileImageUrl = userProvider.profileImageUrl;
    final commentController = TextEditingController();

    void addComment() {
      if (commentController.text.isNotEmpty) {
        final newComment = Comment(
          id: DateTime.now().millisecondsSinceEpoch,
          content: commentController.text,
          postId: post.id,
          userId: currentUserId!,
        );
        Provider.of<PostProvider>(context, listen: false).addComment(post.id, newComment);
        commentController.clear();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (currentUserProfileImageUrl != null)
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(currentUserProfileImageUrl),
                ),
                title: Text('User ID: ${post.userId}'),
                subtitle: Text(post.title),
              ),
            const SizedBox(height: 10),
            Text(
              post.content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Text(
              'Comments',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: post.comments.length,
                itemBuilder: (context, index) {
                  final comment = post.comments[index];
                  return ListTile(
                    title: Text(comment.content),
                    subtitle: Text('User ID: ${comment.userId}'),
                    trailing: comment.userId == currentUserId
                        ? IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              Provider.of<PostProvider>(context, listen: false).deleteComment(post.id, comment.id);
                            },
                          )
                        : null,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        hintText: 'Add a comment',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: addComment,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
