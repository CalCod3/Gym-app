import 'package:WOD_Book/pages/social/challenge.dart';
import 'package:flutter/material.dart';

class PublicProfileScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$userName\'s Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile image and name
            CircleAvatar(
              radius: 50,
              backgroundImage: userProfileImageUrl.isNotEmpty
                  ? NetworkImage(userProfileImageUrl)
                  : null, // If userProfileImageUrl is not empty, use it as the background image
              child: userProfileImageUrl.isEmpty
                  ? Icon(
                      Icons.account_circle_outlined, // Show the icon when the image URL is empty
                      size: 40.0, // Adjust size as needed
                      color: Colors.grey, // Customize the color if necessary
                    )
                  : null, // Don't show the icon when there is an image URL
            ),

            const SizedBox(height: 16),
            Text(
              userName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            // Follow button
            ElevatedButton(
              onPressed: () {
                // Follow logic will go here
              },
              child: const Text('Follow'),
            ),
            const SizedBox(height: 16),
            // Challenge button
            ElevatedButton(
              onPressed: () {
                // Navigate to Challenge screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ChallengeScreen(userId: userId, userName: userName),
                  ),
                );
              },
              child: const Text('Challenge'),
            ),
          ],
        ),
      ),
    );
  }
}
