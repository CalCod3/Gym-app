import 'package:flutter/material.dart';
import 'package:flutter_dashboard/responsive.dart';
import 'package:flutter_dashboard/const.dart';
import 'package:flutter_dashboard/widgets/profile/widgets/scheduled.dart';
import 'package:flutter_dashboard/widgets/profile/widgets/weightHeightBloodCard.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return FutureBuilder(
      future: userProvider.fetchUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(Responsive.isMobile(context) ? 10 : 30.0),
                topLeft: Radius.circular(Responsive.isMobile(context) ? 10 : 30.0),
              ),
              color: cardBackgroundColor,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    userProvider.profileImageUrl != null
                      ? Image.network(userProvider.profileImageUrl!)
                      : Image.asset("assets/images/avatar.jpg"),
                    const SizedBox(height: 15),
                    Text(
                      userProvider.name ?? "Unknown",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Edit Profile details",
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(Responsive.isMobile(context) ? 15 : 20.0),
                      child: const WeightHeightBloodCard(),
                    ),
                    SizedBox(height: Responsive.isMobile(context) ? 20 : 40),
                    Scheduled(),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
