import 'package:flutter/material.dart';
// Adjust imports accordingly

class EulaScreen extends StatelessWidget {
  final VoidCallback onAgree;

  const EulaScreen({required this.onAgree, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("End User License Agreement")),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                // Paste the EULA text here or fetch it from an API.
                "END USER LICENSE AGREEMENT\n\n"
                "[Insert your EULA text here]",
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onAgree,
                  child: const Text("I Agree"),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Exit App"),
                      content: const Text("Are you sure you want to exit?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                          child: const Text("Exit"),
                        ),
                      ],
                    ),
                  ),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("I Disagree"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
