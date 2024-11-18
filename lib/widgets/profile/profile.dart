import 'package:flutter/material.dart';
import 'package:WOD_Book/responsive.dart';
import 'package:WOD_Book/const.dart';
import 'package:WOD_Book/widgets/profile/widgets/scheduled.dart';
import 'package:WOD_Book/widgets/profile/widgets/weightHeightBloodCard.dart';
import 'package:provider/provider.dart';
import '../../pages/payments/payment_plans.dart';
import '../../providers/user_provider.dart';

// ignore: must_be_immutable
class Profile extends StatelessWidget {
  Profile({super.key});

  Future<void>? _fetchUserDataFuture;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    _fetchUserDataFuture ??= userProvider.fetchUserData();

    return Scaffold(
      body: FutureBuilder(
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
                  bottomLeft:
                      Radius.circular(Responsive.isMobile(context) ? 10 : 30.0),
                  topLeft:
                      Radius.circular(Responsive.isMobile(context) ? 10 : 30.0),
                ),
                color: cardBackgroundColor,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 50),
                      Consumer<UserProvider>(
                        builder: (context, userProvider, child) {
                          return userProvider.profileImageUrl != null
                              ? Image.network(userProvider.profileImageUrl!)
                              : Icon(
                                  Icons.account_circle_outlined, // Use the account_circle_outlined icon
                                  size:50.0, // Set the size of the icon (you can adjust it as needed)
                                  color: Colors.grey, // Set the color of the icon (you can adjust it as needed)
                                );
                        },
                      ),
                      const SizedBox(height: 15),
                      Consumer<UserProvider>(
                        builder: (context, userProvider, child) {
                          return Text(
                            userProvider.name ?? "Unknown",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          );
                        },
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
                        padding: EdgeInsets.all(
                            Responsive.isMobile(context) ? 15 : 20.0),
                        child: const WeightHeightBloodCard(),
                      ),
                      const SizedBox(height: 20),
                      Consumer<UserProvider>(
                        builder: (context, userProvider, child) {
                          return _buildMembershipStatus(context, userProvider);
                        },
                      ),
                      const SizedBox(height: 20),
                      const Scheduled(),
                      const SizedBox(height: 15),
                      Consumer<UserProvider>(
                        builder: (context, userProvider, child) {
                          return Text(
                            userProvider.name ?? "Unknown",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildMembershipStatus(
      BuildContext context, UserProvider userProvider) {
    String membershipStatus = userProvider.isMembershipActive
        ? 'Membership Status: Active'
        : 'Membership Status: Inactive';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PaymentPlansPage()),
        );
      },
      child: Text(
        membershipStatus,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}
