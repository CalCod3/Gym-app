// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class ChallengeScreen extends StatefulWidget {
  final int userId;
  final String userName;

  const ChallengeScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  _ChallengeScreenState createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  bool _isChallengeSent = false;

  void _sendChallenge() {
    setState(() {
      _isChallengeSent = true;
    });

    // Logic to send the challenge goes here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Challenge ${widget.userName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Challenge ${widget.userName} to a performance milestone!',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            // Challenge button with state change
            ElevatedButton.icon(
              onPressed: _isChallengeSent ? null : _sendChallenge,
              icon: _isChallengeSent
                  ? const Icon(Icons.check) // Show a tick icon when challenge is sent
                  : const Icon(Icons.send), // Default icon (send)
              label: Text(_isChallengeSent ? 'Challenge Sent' : 'Send Challenge'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isChallengeSent ? Colors.green : Colors.blue, // Change color based on state
              ),
            ),
          ],
        ),
      ),
    );
  }
}
