// pages/activity_details_card.dart
import 'package:flutter/material.dart';
import 'package:fit_nivel/providers/activity_provider.dart';
import 'package:fit_nivel/widgets/custom_card.dart';
import 'package:provider/provider.dart';
import '../../../pages/home/activity_detail_screen.dart';
import '../../../responsive.dart';

class ActivityDetailsCard extends StatefulWidget {
  const ActivityDetailsCard({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ActivityDetailsCardState createState() => _ActivityDetailsCardState();
}

class _ActivityDetailsCardState extends State<ActivityDetailsCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
                mainAxisSpacing: 12.0),
            itemBuilder: (context, i) {
              final activity = activities[i];
              return GestureDetector(
                onTap: () {
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
                        activity.image,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15, bottom: 4),
                        child: Text(
                          activity.value,
                          style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        activity.title,
                        style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}
