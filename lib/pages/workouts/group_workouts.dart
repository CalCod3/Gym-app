// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workout_provider.dart';

class GroupWorkoutCreateScreen extends StatelessWidget {
  const GroupWorkoutCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group Workout'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: GroupWorkoutForm(),
      ),
    );
  }
}


class GroupWorkoutForm extends StatelessWidget {
  const GroupWorkoutForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupWorkoutProvider>(
      builder: (context, provider, child) {
        return Form(
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Title'),
                  onChanged: provider.setTitle,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Description'),
                  onChanged: provider.setDescription,
                ),
                ListTile(
                  title: Text(provider.date == null
                      ? 'Select Date'
                      : provider.date.toString()),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null) {
                      provider.setDate(picked);
                    }
                  },
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: provider.videoLinks.length,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'YouTube Video Link ${index + 1}',
                            ),
                            onChanged: (value) => provider.updateVideoLink(index, value),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => provider.removeVideoLink(index),
                        ),
                      ],
                    );
                  },
                ),
                TextButton(
                  onPressed: provider.addVideoLink,
                  child: const Text('Add Another Video Link'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: provider.isValid()
                      ? () async {
                          try {
                            final success = await provider.createGroupWorkout(context);
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Group Workout Created')),
                              );
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Failed to create group workout')),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('An error occurred')),
                            );
                          }
                        }
                      : null,
                  child: const Text('Create Group Workout'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
