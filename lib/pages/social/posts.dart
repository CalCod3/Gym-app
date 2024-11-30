// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../const.dart';
import '../../providers/post_provider.dart';
import 'post_create.dart';
import 'post_detail.dart';
import 'comment_create.dart';
import 'public_profile.dart';

class PostsScreen extends StatelessWidget {
  PostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
      ),
      body: FutureBuilder(
        future: Provider.of<PostProvider>(context, listen: false).fetchPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Consumer<PostProvider>(
              builder: (context, postProvider, child) {
                return ListView.builder(
                  itemCount: postProvider.posts.length,
                  itemBuilder: (context, index) {
                    final post = postProvider.posts[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PostDetailScreen(post: post),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: cardBackgroundColor,
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: const [
                              BoxShadow(
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header with profile image and username
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PublicProfileScreen(
                                              userId: post.userId,
                                              userName: post.userName,
                                              userProfileImageUrl:
                                                  post.userProfileImageUrl,
                                            ),
                                          ),
                                        );
                                      },
                                      child: CircleAvatar(
                                        backgroundImage: post
                                                .userProfileImageUrl.isNotEmpty
                                            ? NetworkImage(
                                                post.userProfileImageUrl)
                                            : null, // If userProfileImageUrl is not empty, use it as the background image
                                        child: post.userProfileImageUrl.isEmpty
                                            ? Icon(
                                                Icons
                                                    .account_circle_outlined, // Show the icon when the image URL is empty
                                                size:
                                                    30.0, // Adjust size as needed
                                                color: Colors
                                                    .grey, // Customize the color if necessary
                                              )
                                            : null, // Don't show the icon when there is an image URL
                                      ),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PublicProfileScreen(
                                                userId: post.userId,
                                                userName: post.userName,
                                                userProfileImageUrl:
                                                    post.userProfileImageUrl,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          post.userName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Post content
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  post.content,
                                  style: const TextStyle(fontSize: 16.0),
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              // Interaction buttons
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 4.0),
                                child: Row(
                                  children: [
                                    Consumer<PostProvider>(
                                      builder: (context, postProvider, child) {
                                        return IconButton(
                                          icon: const Icon(
                                              Icons.thumb_up_outlined),
                                          onPressed: () {
                                            postProvider.addLike(post.id);
                                          },
                                        );
                                      },
                                    ),
                                    Text('${post.likesCount}'),
                                    const SizedBox(width: 16.0),
                                    IconButton(
                                      icon: const Icon(Icons.comment_outlined),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CommentCreateScreen(
                                                    postId: post.id),
                                          ),
                                        );
                                      },
                                    ),
                                    Text('${post.comments.length}'),
                                    const SizedBox(width: 16.0),
                                    // Report button
                                    IconButton(
                                      icon: const Icon(Icons.report_outlined),
                                      onPressed: () {
                                        _showReportDialog(context, post.id);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
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

  final TextEditingController _reasonController = TextEditingController();

  void _showReportDialog(BuildContext context, int postId) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Report Post'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please provide a brief reason for reporting:'),
              TextField(
                controller: _reasonController,
                decoration: const InputDecoration(hintText: 'Reason'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final reason = _reasonController.text;
                if (reason.isNotEmpty) {
                  _reportPost(context, postId, reason);
                  Navigator.of(ctx).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a reason')),
                  );
                }
              },
              child: const Text('Report'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _reportPost(
      BuildContext context, int postId, String reason) async {
    try {
      await Provider.of<PostProvider>(context, listen: false)
          .reportPost(postId, reason);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post has been reported.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to report post: $e')),
      );
    }
  }
}
