import 'package:flutter/material.dart';
import 'package:flutter_dashboard/responsive.dart';
import 'package:flutter_dashboard/const.dart';
import 'package:flutter_dashboard/widgets/profile/widgets/scheduled.dart';
import 'package:flutter_dashboard/widgets/profile/widgets/weightHeightBloodCard.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

// ignore: must_be_immutable
class Profile extends StatelessWidget {
  Profile({super.key});

  Future<void>? _fetchUserDataFuture;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    _fetchUserDataFuture ??= userProvider.fetchUserData();

    return FutureBuilder(
      future: _fetchUserDataFuture,
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
                    const SizedBox(height: 20),
                    _buildMembershipStatus(userProvider),
                    const SizedBox(height: 20),
                    Scheduled(),
                    const SizedBox(height: 15),
                    Text(
                      userProvider.name ?? "Unknown",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildMembershipStatus(UserProvider userProvider) {
    String membershipStatus = userProvider.isMembershipActive
        ? 'Membership Status: Active'
        : 'Membership Status: Inactive';

    return Text(
      membershipStatus,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }
}
