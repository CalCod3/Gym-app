// ignore_for_file: deprecated_member_use, unused_field, library_private_types_in_public_api

import 'package:wod_book/pages/schedule/calendar.dart';
import 'package:wod_book/pages/schedule/classes.dart';
import 'package:flutter/material.dart';
import 'package:wod_book/pages/admin/communications.dart';
import 'package:wod_book/pages/social/posts.dart';
import 'package:wod_book/responsive.dart';
import 'package:wod_book/model/menu_modal.dart';
import 'package:wod_book/pages/leaderboard/leaderboard.dart';
import 'package:wod_book/widgets/profile/profilepage.dart';
import 'package:wod_book/auth/login_page.dart'; // Assume you handle signout via login page
import 'package:wod_book/auth/auth_provider.dart';
import 'package:provider/provider.dart';

import '../pages/admin/activities.dart';
import '../pages/admin/members.dart';
import '../pages/payments/payment_plan_create.dart';
import '../pages/workouts/workouts.dart';

class Menu extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const Menu({super.key, required this.scaffoldKey});

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  late List<MenuModel> menu;
  late AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _buildMenu();
  }

  void _buildMenu() {
    menu = [
      if (_authProvider.isAdmin ?? false)
        MenuModel(
          icon: Icons.admin_panel_settings,
          title: "Admin",
          children: [
            MenuModel(
              icon: Icons.corporate_fare,
              title: "Box",
              children: [
                MenuModel(
                  icon: Icons.people,
                  title: "Members",
                  route: const MembersScreen(),
                ),
              ],
            ),
            MenuModel(
              icon: Icons.event,
              title: "Activities",
              route: const ActivityListScreen(),
            ),
            MenuModel(
              icon: Icons.message,
              title: "Communications Center",
              route: const CommunicationsScreen(),
            ),
            MenuModel(
              icon: Icons.payments,
              title: "Finance Manager",
              children: [
                MenuModel(
                  icon: Icons.account_balance_wallet,
                  title: "Payment Plans",
                  route: const CreatePaymentPlanPage(),
                ),
              ],
            ),
          ],
        ),
      if (_authProvider.isCoach ?? false)
        MenuModel(
          icon: Icons.co_present,
          title: "Coach",
          children: [
            MenuModel(
              icon: Icons.class_,
              title: "Classes",
              route: const AddClassScreen(),
            ),
            MenuModel(
              icon: Icons.fitness_center,
              title: "Group Workouts",
              route: const GroupWorkoutsListScreen(),
            ),
          ],
        ),
      MenuModel(
        icon: Icons.dashboard,
        title: "Dashboard",
        // Add a flag or custom logic to indicate this item should only close the drawer
        isDashboard: true,
      ),
      MenuModel(
        icon: Icons.person,
        title: "Profile",
        route: ProfilePage(),
      ),
      MenuModel(
        icon: Icons.calendar_today,
        title: "Exercise Schedule",
        route: const CalendarScreen(),
      ),
      MenuModel(
        icon: Icons.group,
        title: "Community",
        route: PostsScreen(),
      ),
      MenuModel(
        icon: Icons.leaderboard,
        title: "Leaderboard",
        route: const LeaderboardScreen(),
      ),
      MenuModel(
        icon: Icons.logout,
        title: "Signout",
        route: const LoginPage(),
      ),
    ];
  }

  Widget _buildMenuItem(MenuModel menuItem) {
    if (menuItem.children != null && menuItem.children!.isNotEmpty) {
      return ExpansionTile(
        leading: Icon(
          menuItem.icon,
          color: Colors.white,
        ),
        title: Text(
          menuItem.title,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        children: menuItem.children!.map(_buildMenuItem).toList(),
      );
    } else {
      return ListTile(
        leading: Icon(
          menuItem.icon,
          color: Colors.white,
        ),
        title: Text(
          menuItem.title,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        onTap: () {
          // Close the drawer
          widget.scaffoldKey.currentState!.closeDrawer();

          // Handle the "Dashboard" case
          if (menuItem.isDashboard == true) {
            // Do nothing else, just close the drawer
            return;
          }

          // Navigate to the route for other items
          if (menuItem.route != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => menuItem.route!),
            );
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Colors.grey[800]!,
            width: 1,
          ),
        ),
        color: const Color(0xFF171821),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: Responsive.isMobile(context) ? 40 : 80,
              ),
              ...menu.map(_buildMenuItem).toList(),
            ],
          ),
        ),
      ),
    );
  }
}