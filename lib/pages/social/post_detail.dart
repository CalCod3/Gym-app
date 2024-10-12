import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/post_model.dart';
import '../../providers/post_provider.dart';
import '../../providers/user_provider.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({required this.post, super.key});

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
    // Optionally fetch comments if not already done
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PostProvider>(context, listen: false).fetchComments(widget.post.id);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _addComment() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUserId = userProvider.authProvider?.userId;
    if (currentUserId == null || _commentController.text.isEmpty) return;

    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch,
      content: _commentController.text,
      postId: widget.post.id,
      userId: currentUserId,
    );

    Provider.of<PostProvider>(context, listen: false).addComment(widget.post.id, newComment)
      .then((_) {
        _commentController.clear();
        // Optionally refresh comments if needed
        Provider.of<PostProvider>(context, listen: false).fetchComments(widget.post.id);
      });
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final userProvider = Provider.of<UserProvider>(context);
    final currentUserId = userProvider.authProvider?.userId;

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
                      backgroundImage: userProvider.profileImageUrl != null
                          ? NetworkImage(userProvider.profileImageUrl!)
                          : const NetworkImage("https://cdns.iconmonstr.com/wp-content/releases/preview/2012/240/iconmonstr-user-6.png") as ImageProvider,
                    ),
                    title: Text(comment.content),
                    subtitle: Text('User ID: ${comment.userId}'),
                    trailing: comment.userId == currentUserId
                        ? IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              Provider.of<PostProvider>(context, listen: false)
                                  .deleteComment(post.id, comment.id);
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
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Add a comment',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _addComment,
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
