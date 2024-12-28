// pages/activity_details_card.dart
// ignore_for_file: library_private_types_in_public_api

import 'package:WOD_Book/pages/home/activity_detail_screen.dart';
import 'package:WOD_Book/providers/activity_provider.dart';
import 'package:WOD_Book/responsive.dart';
import 'package:WOD_Book/widgets/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class ActivityDetailsCard extends StatefulWidget {
  const ActivityDetailsCard({super.key});

  @override
  _ActivityDetailsCardState createState() => _ActivityDetailsCardState();
}

class _ActivityDetailsCardState extends State<ActivityDetailsCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch activities when the widget is initialized
      Provider.of<ActivityProvider>(context, listen: false).fetchActivities();
    });
  }

  @override
  Widget build(BuildContext context) {
    final activityProvider = Provider.of<ActivityProvider>(context);
    final activities = activityProvider.activities;

    return activityProvider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : GridView.builder(
            itemCount: activities.length,
            shrinkWrap: true,
            physics: const ScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: Responsive.isMobile(context) ? 2 : 4,
              crossAxisSpacing: !Responsive.isMobile(context) ? 15 : 12,
              mainAxisSpacing: 12.0,
            ),
            itemBuilder: (context, i) {
              final activity = activities[i];

              return GestureDetector(
                onTap: () {
                  // Navigate to ActivityDetailScreen with the selected activity
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActivityDetailScreen(activity: activity),
                    ),
                  );
                },
                child: CustomCard(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.network(
                        activity.image ?? '', // Handle null safety
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 90,
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15, bottom: 4),
                        child: Text(
                          activity.value!,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        activity.title!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}
