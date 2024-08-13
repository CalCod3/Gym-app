import 'package:flutter/material.dart';
import 'package:fit_nivel/pages/home/home_page.dart';
import 'package:fit_nivel/widgets/menu.dart';
import 'package:fit_nivel/responsive.dart';
import 'package:fit_nivel/widgets/profile/profile.dart';

class DashBoard extends StatelessWidget {
  DashBoard({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        drawer: !Responsive.isDesktop(context)
            ? SizedBox(width: 250, child: Menu(scaffoldKey: _scaffoldKey))
            : null,
        endDrawer: Responsive.isMobile(context)
            ? SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Profile())
            : null,
        body: SafeArea(
          child: Row(
            children: [
              if (Responsive.isDesktop(context))
                Expanded(
                  flex: 3,
                  child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: Menu(scaffoldKey: _scaffoldKey)),
                ),
              Expanded(flex: 8, child: HomePage(scaffoldKey: _scaffoldKey)),
              if (!Responsive.isMobile(context))
                Expanded(
                  flex: 4,
                  child: Profile(),
                ),
            ],
          ),
        ));
  }
}
