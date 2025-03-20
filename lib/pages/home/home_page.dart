import 'package:flutter/material.dart';
import 'package:wod_book/pages/home/widgets/header_widget.dart';
import 'package:wod_book/responsive.dart';
import 'package:wod_book/pages/home/widgets/activity_details_card.dart';
import 'package:wod_book/pages/home/widgets/line_chart_card.dart';

import 'widgets/news_summary_card.dart';

class HomePage extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const HomePage({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    SizedBox height(BuildContext context) => SizedBox(
          height: Responsive.isDesktop(context) ? 30 : 20,
        );

    return SizedBox(
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
            child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: Responsive.isMobile(context) ? 15 : 18),
          child: Column(
            children: [
              SizedBox(
                height: Responsive.isMobile(context) ? 5 : 18,
              ),
              Header(scaffoldKey: scaffoldKey),
              height(context),
              const ActivityDetailsCard(),
              height(context),
              const NewsSummaryCard(), // Add the news summary card here
              height(context),
              const LineChartCard(),
              height(context),
            ],
          ),
        )));
  }
}
