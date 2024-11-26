// ignore_for_file: deprecated_member_use, unused_field

import 'package:WOD_Book/pages/schedule/calendar.dart';
import 'package:WOD_Book/pages/schedule/classes.dart';
import 'package:flutter/material.dart';
import 'package:WOD_Book/pages/admin/communications.dart';
import 'package:WOD_Book/pages/home/home_page.dart';
import 'package:WOD_Book/pages/social/posts.dart';
import 'package:WOD_Book/responsive.dart';
import 'package:WOD_Book/model/menu_modal.dart';
import 'package:WOD_Book/pages/leaderboard/leaderboard.dart';
import 'package:WOD_Book/widgets/profile/profile.dart';
import 'package:WOD_Book/auth/login_page.dart'; // Assume you handle signout via login page
import 'package:WOD_Book/auth/auth_provider.dart';
import 'package:provider/provider.dart';

import '../pages/admin/activities.dart';
import '../pages/admin/members.dart';
import '../pages/payments/payment_plan_create.dart';
import '../pages/workouts/workouts.dart';

class Menu extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const Menu({super.key, required this.scaffoldKey});

  @override
  // ignore: library_private_types_in_public_api
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  late List<MenuModel> menu;
  late AuthProvider _authProvider;
  final bool _isAdminExpanded = false;

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Build the menu based on admin status
    _buildMenu();
  }

  void _buildMenu() {
    menu = [
      if (_authProvider.isAdmin ?? false)
        MenuModel(
          icon: Icons.admin_panel_settings,
          title: "Admin",
          route: Container(), // Placeholder route for the dropdown
          children: [
            MenuModel(
              icon: Icons.corporate_fare,
              title: "Box",
              route: Container(),
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
              route: Container(), // Placeholder for the nested dropdown
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
          route: Container(), // Placeholder route for the dropdown
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
        route: HomePage(scaffoldKey: widget.scaffoldKey),
      ),
      MenuModel(
        icon: Icons.person,
        title: "Profile",
        route: Profile(),
      ),
      MenuModel(
        icon: Icons.calendar_today,
        title: "Exercise Schedule",
        route: const CalendarScreen(),
      ),
      MenuModel(
        icon: Icons.group,
        title: "Community",
        route: const PostsScreen(),
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

  int selected = 0;

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
              for (var i = 0; i < menu.length; i++)
                menu[i].children != null
                    ? ExpansionTile(
                        leading: Icon(
                          menu[i].icon,
                          color: Colors.white,
                        ),
                        title: Text(
                          menu[i].title,
                          style: TextStyle(
                            fontSize: 16,
                            color: selected == i ? Colors.white : Colors.grey,
                            fontWeight: selected == i
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        children: menu[i].children!.map((child) {
                          return ListTile(
                            leading: Icon(
                              child.icon,
                              color: Colors.white,
                            ),
                            title: Text(
                              child.title,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                selected = i;
                              });
                              widget.scaffoldKey.currentState!.closeDrawer();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => child.route),
                              );
                            },
                          );
                        }).toList(),
                      )
                    : ListTile(
                        leading: Icon(
                          menu[i].icon,
                          color: selected == i
                              ? Theme.of(context).primaryColor
                              : Colors.white,
                        ),
                        title: Text(
                          menu[i].title,
                          style: TextStyle(
                            fontSize: 16,
                            color: selected == i ? Colors.white : Colors.grey,
                            fontWeight: selected == i
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            selected = i;
                          });
                          widget.scaffoldKey.currentState!.closeDrawer();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => menu[i].route),
                          );
                        },
                      ),
            ],
          ),
        ),
      ),
    );
  }
}
