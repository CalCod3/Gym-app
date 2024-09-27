import 'package:flutter/material.dart';

class ChallengeScreen extends StatelessWidget {
  final int userId;
  final String userName;

  const ChallengeScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Challenge $userName'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Challenge $userName to a performance milestone!',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            // You can add fields for selecting performance milestones here
            ElevatedButton(
              onPressed: () {
                // Logic to send the challenge
              },
              child: const Text('Send Challenge'),
            ),
          ],
        ),
      ),
    );
  }
}
