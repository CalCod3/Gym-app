// ignore_for_file: deprecated_member_use

import 'package:WOD_Book/pages/schedule/classes.dart';
import 'package:flutter/material.dart';
import 'package:WOD_Book/pages/admin/communications.dart';
import 'package:WOD_Book/pages/home/home_page.dart';
import 'package:WOD_Book/pages/social/posts.dart';
import 'package:WOD_Book/responsive.dart';
import 'package:WOD_Book/model/menu_modal.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:WOD_Book/pages/leaderboard/leaderboard.dart';
import 'package:WOD_Book/pages/schedule/schedule.dart';
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
  // ignore: unused_field
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
          icon: 'svg/admin.svg',
          title: "Admin",
          route: Container(), // Placeholder route for the dropdown
          children: [
            MenuModel(
              icon:
                  'svg/box.svg', // Provide an appropriate icon for Box
              title: "Box",
              route: Container(),
              children: [
                MenuModel(
                  icon:'svg/members.svg', // Provide an appropriate icon for Members
                  title: "Members",
                  route: const MembersScreen(),
                  ),
                MenuModel(
                  icon:'svg/settings.svg', // Provide an appropriate icon for Members
                  title: "Settings",
                  route: Container(),
                  ),
              ]
            ),
            MenuModel(
              icon: 'svg/events.svg',
              title: "Activities",
              route: const ActivityListScreen(),
            ),
            MenuModel(
              icon: 'svg/communications.svg',
              title: "Communications Center",
              route: const CommunicationsScreen(),
            ),
            MenuModel(
              icon: 'svg/payments.svg',
              title: "Finance Manager",
              route: Container(), // Placeholder for the nested dropdown
              children: [
                MenuModel(
                  icon: 'svg/plan.svg',
                  title: "Payment Plans",
                  route: const CreatePaymentPlanPage(),
                ),
                MenuModel(
                  icon: 'svg/wage.svg',
                  title: "Wages",
                  route: Container(),
                  ),
              ],
            ),
          ],
        ),
      if (_authProvider.isCoach ?? false)
        MenuModel(
          icon: 'svg/coach.svg',
          title: "Coach",
          route: Container(), // Placeholder route for the dropdown
          children: [
            MenuModel(
              icon:
                  'svg/classes.svg', // Provide an appropriate icon for classes
              title: "Classes",
              route: const AddClassScreen(),
            ),
            MenuModel(
              icon:
                  'svg/groupworkouts.svg', // Provide an appropriate icon for Members
              title: "Group Workouts",
              route: const GroupWorkoutsListScreen(),
            ),
          ],
        ),
      MenuModel(
        icon: 'svg/home.svg',
        title: "Dashboard",
        route: HomePage(scaffoldKey: widget.scaffoldKey),
      ),
      MenuModel(
        icon: 'svg/profile.svg',
        title: "Profile",
        route: Profile(),
      ),
      MenuModel(
        icon: 'svg/exercise.svg',
        title: "Exercise Schedule",
        route: const ScheduleScreen(),
      ),
      MenuModel(
        icon: 'svg/community.svg',
        title: "Community",
        route: const PostsScreen(),
      ),
      MenuModel(
        icon: 'svg/history.svg',
        title: "Leaderboard",
        route: const LeaderboardScreen(),
      ),
      MenuModel(
        icon: 'svg/signout.svg',
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
                        leading: SvgPicture.asset(
                          menu[i].icon),
                        title: Text(
                          menu[i].title,
                          style: TextStyle(
                            fontSize: 16,
                            color: selected == i ? const Color.fromARGB(255, 255, 255, 255) : Colors.grey,
                            fontWeight: selected == i
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        children: menu[i].children!.map((child) {
                          return child.children != null
                              ? ExpansionTile(
                                  leading: SvgPicture.asset(
                                    child.icon),
                                  title: Text(
                                    child.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: selected == i
                                          ? Colors.black
                                          : Colors.grey,
                                      fontWeight: selected == i
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  children: child.children!.map((subChild) {
                                    return ListTile(
                                      leading: SvgPicture.asset(
                                        subChild.icon),
                                      title: Text(
                                        subChild.title,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: selected == i
                                              ? const Color.fromARGB(255, 255, 255, 255)
                                              : Colors.grey,
                                          fontWeight: selected == i
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          selected = i;
                                        });
                                        widget.scaffoldKey.currentState!
                                            .closeDrawer();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  subChild.route),
                                        );
                                      },
                                    );
                                  }).toList(),
                                )
                              : ListTile(
                                  leading: SvgPicture.asset(
                                    child.icon),
                                  title: Text(
                                    child.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: selected == i
                                          ? const Color.fromARGB(255, 255, 255, 255)
                                          : Colors.grey,
                                      fontWeight: selected == i
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      selected = i;
                                    });
                                    widget.scaffoldKey.currentState!
                                        .closeDrawer();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => child.route),
                                    );
                                  },
                                );
                        }).toList(),
                      )
                    : Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(6.0),
                          ),
                          color: selected == i
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                        ),
                        child: InkWell(
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
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 13, vertical: 7),
                                child: SvgPicture.asset(
                                  menu[i].icon),
                              ),
                              Text(
                                menu[i].title,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: selected == i
                                      ? const Color.fromARGB(255, 255, 255, 255)
                                      : Colors.grey,
                                  fontWeight: selected == i
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
            ],
          ),
        ),
      ),
    );
  }
}
