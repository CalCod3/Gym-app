// screens/post_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/post_model.dart';
import '../../providers/post_provider.dart';
import '../../providers/user_provider.dart';
import 'comment_create.dart'; // Import for CommentCreate screen

class PostDetailScreen extends StatelessWidget {
  final Post post;

  const PostDetailScreen({required this.post, super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUserId = userProvider.authProvider?.userId;
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
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with profile image and username of the post owner
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: post.userProfileImageUrl.isNotEmpty
                      ? NetworkImage(post.userProfileImageUrl)
                      : const AssetImage('images/avatar.png') as ImageProvider,
                  radius: 24.0,
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '@${post.userId}', // Assuming you want to show the userId as the handle
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${post.likesCount} likes',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              post.content,
              style: Theme.of(context).textTheme.bodyLarge,
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
                    leading: CircleAvatar(
                      backgroundImage: post.userProfileImageUrl.isNotEmpty
                          ? NetworkImage(post.userProfileImageUrl)
                          : const AssetImage('images/avatar.png') as ImageProvider,
                    ),
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
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
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
