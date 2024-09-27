// screens/leaderboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/performance_provider.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
      ),
      body: Consumer<PerformanceProvider>(
        builder: (context, performanceProvider, child) {
          return FutureBuilder(
            future: performanceProvider.fetchLeaderboard(),
            builder: (context, snapshot) {
              if (performanceProvider.isLoading || snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                final leaderboard = performanceProvider.leaderboard;

                // Check if the leaderboard is empty
                if (leaderboard.isEmpty) {
                  return const Center(
                    child: Text('No entries available.'),
                  );
                }

                return ListView.builder(
                  itemCount: leaderboard.length,
                  itemBuilder: (context, index) {
                    final performance = leaderboard[index];
                    return ListTile(
                      title: Text(performance.category),
                      subtitle: Text('Weight: ${performance.weight}'),
                    );
                  },
                );
              }
            },
          );
        },
      ),
    );
  }
}
