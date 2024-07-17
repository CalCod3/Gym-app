// screens/posts_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_dashboard/auth/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../providers/post_provider.dart';
import '../../providers/user_provider.dart';
import 'post_create.dart';
import 'post_detail.dart';

class PostsScreen extends StatelessWidget {
  const PostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    // ignore: unused_local_variable
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserProfileImageUrl = userProvider.profileImageUrl;
    final currentUserName = userProvider.name;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
      ),
      body: Consumer<PostProvider>(
        builder: (context, postProvider, child) {
          return ListView.builder(
            itemCount: postProvider.posts.length,
            itemBuilder: (context, index) {
              final post = postProvider.posts[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(currentUserProfileImageUrl!),
                ),
                title: Text(post.title),
                subtitle: Text(post.content),
                trailing: Text(currentUserName!),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostDetailScreen(post: post),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NewPostScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
