// ignore_for_file: avoid_print, library_private_types_in_public_api

import 'package:wod_book/pages/social/challenge.dart';
import 'package:wod_book/providers/post_provider.dart';
import 'package:wod_book/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PublicProfileScreen extends StatefulWidget {
  final int userId;
  final String userName;
  final String userProfileImageUrl;

  const PublicProfileScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.userProfileImageUrl,
  });

  @override
  _PublicProfileScreenState createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  bool isBlocked = false;

  @override
  void initState() {
    super.initState();
    // Check if the user is blocked
    _checkIfUserIsBlocked();
  }

  // Asynchronous method to check if the user is blocked
  Future<void> _checkIfUserIsBlocked() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      bool isBlockedStatus = await userProvider.isUserBlocked(widget.userId);
      setState(() {
        isBlocked = isBlockedStatus;
      });
    } catch (e) {
      // Handle any errors during the block check
      print("Error checking block status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.userName}\'s Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile image
            CircleAvatar(
              radius: 50,
              backgroundImage: widget.userProfileImageUrl.isNotEmpty
                  ? NetworkImage(widget.userProfileImageUrl)
                  : null,
              child: widget.userProfileImageUrl.isEmpty
                  ? Icon(
                      Icons.account_circle_outlined,
                      size: 40.0,
                      color: Colors.grey,
                    )
                  : null,
            ),

            const SizedBox(height: 16),
            // Username
            Text(
              widget.userName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),

            // Blocked message and buttons
            if (isBlocked)
              const Center(
                child: Text(
                  'This user has been blocked.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Follow button
                    ElevatedButton(
                      onPressed: () {
                        // Follow logic will go here
                      },
                      child: const Text('Follow'),
                    ),
                    const SizedBox(width: 16),
                    // Challenge button
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to Challenge screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChallengeScreen(
                                userId: widget.userId, userName: widget.userName),
                          ),
                        );
                      },
                      child: const Text('Challenge'),
                    ),
                    const SizedBox(width: 16),
                    // Block button with icon
                    ElevatedButton.icon(
                      onPressed: () async {
                        // Block the user (replace with actual current user ID)
                        await userProvider.blockUser(widget.userId);
                      },
                      icon: const Icon(Icons.block),
                      label: const Text('Block'),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // Display posts if not blocked
            if (!isBlocked)
              Expanded(
                child: Consumer<PostProvider>(
                  builder: (context, postProvider, child) {
                    return FutureBuilder<void>(
                      future: postProvider.fetchPostsByUser(widget.userId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error fetching posts: ${snapshot.error}'),
                          );
                        }

                        // Access the filtered posts after fetching
                        final userPosts = postProvider.posts;

                        if (userPosts.isEmpty) {
                          return const Center(child: Text('No posts available.'));
                        }

                        return ListView.builder(
                          itemCount: userPosts.length,
                          itemBuilder: (context, index) {
                            final post = userPosts[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                title: Text(post.title),
                                subtitle: Text(post.content),
                              ),
                            );
                          },
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
}
