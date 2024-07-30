// screens/group_workout_list_screen.dart
// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/workout_provider.dart'; // Correct the import
import 'group_workouts.dart'; // Import the screen to navigate to

class GroupWorkoutsListScreen extends StatefulWidget {
  const GroupWorkoutsListScreen({super.key});

  @override
  _GroupWorkoutsListScreenState createState() => _GroupWorkoutsListScreenState();
}

class _GroupWorkoutsListScreenState extends State<GroupWorkoutsListScreen> {
  late Future<void> _fetchGroupWorkoutsFuture;

  @override
  void initState() {
    super.initState();
    _fetchGroupWorkoutsFuture = Provider.of<GroupWorkoutProvider>(context, listen: false).fetchGroupWorkouts(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Workouts'),
      ),
      body: Consumer<GroupWorkoutProvider>(
        builder: (context, provider, child) {
          return FutureBuilder<void>(
            future: _fetchGroupWorkoutsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (provider.groupWorkouts.isEmpty) {
                return const Center(child: Text('No group workouts available.'));
              } else {
                return ListView.builder(
                  itemCount: provider.groupWorkouts.length,
                  itemBuilder: (context, index) {
                    final groupWorkout = provider.groupWorkouts[index];
                    return ListTile(
                      title: Text(groupWorkout.name),
                      subtitle: Text(groupWorkout.description),
                      trailing: Text(groupWorkout.date.toLocal().toString()),
                      onTap: () {
                        // Handle tap if needed
                      },
                    );
                  },
                );
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GroupWorkoutCreateScreen()),
          );
        },
        tooltip: 'Add Group Workout',
        child: const Icon(Icons.add),
      ),
    );
  }
}
