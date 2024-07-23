import 'package:flutter/material.dart';
import 'package:flutter_dashboard/pages/home/home_page.dart';
import 'package:flutter_dashboard/pages/social/posts.dart';
import 'package:flutter_dashboard/responsive.dart';
import 'package:flutter_dashboard/model/menu_modal.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_dashboard/pages/leaderboard/leaderboard.dart';
import 'package:flutter_dashboard/pages/schedule/schedule.dart';
import 'package:flutter_dashboard/widgets/profile/profile.dart';
import 'package:flutter_dashboard/auth/login_page.dart'; // Assume you handle signout via login page

class Menu extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const Menu({super.key, required this.scaffoldKey});

  @override
  // ignore: library_private_types_in_public_api
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  late List<MenuModel> menu;

  @override
  void initState() {
    super.initState();
    menu = [
      MenuModel(
          icon: 'assets/svg/home.svg',
          title: "Dashboard",
          route: HomePage(scaffoldKey: widget.scaffoldKey)),
      MenuModel(icon: 'assets/svg/profile.svg', title: "Profile", route: Profile()),
      MenuModel(icon: 'assets/svg/exercise.svg', title: "Exercise Schedule", route: const ScheduleScreen()),
      MenuModel(icon: 'assets/svg/setting.svg', title: "Feeds", route: const PostsScreen()),
      MenuModel(icon: 'assets/svg/history.svg', title: "Leaderboard", route: const LeaderboardScreen()),
      MenuModel(icon: 'assets/svg/signout.svg', title: "Signout", route: const LoginPage()),
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
                Container(
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
                        MaterialPageRoute(builder: (context) => menu[i].route),
                      );
                    },
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                          child: SvgPicture.asset(
                            menu[i].icon,
                            color: selected == i ? Colors.black : Colors.grey,
                          ),
                        ),
                        Text(
                          menu[i].title,
                          style: TextStyle(
                            fontSize: 16,
                            color: selected == i ? Colors.black : Colors.grey,
                            fontWeight: selected == i ? FontWeight.w600 : FontWeight.normal,
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
