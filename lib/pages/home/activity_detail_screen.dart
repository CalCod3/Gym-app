// pages/activity_detail_screen.dart
import 'package:flutter/material.dart';
import '../../model/activity_model.dart';

class ActivityDetailScreen extends StatelessWidget {
  final ActivityModel activity;

  const ActivityDetailScreen({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(activity.title!),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              activity.image ?? '', // Handle null safety for image URL
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                  size: 100,
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              activity.value!,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              activity.description!, // Default message for null description
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
