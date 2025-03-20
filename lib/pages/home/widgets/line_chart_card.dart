// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:wod_book/providers/attendance_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wod_book/responsive.dart';
import 'package:wod_book/widgets/custom_card.dart';

class LineChartCard extends StatefulWidget {
  const LineChartCard({super.key});

  @override
  _LineChartCardState createState() => _LineChartCardState();
}

class _LineChartCardState extends State<LineChartCard> {
  List<FlSpot> spots = [];
  bool isLoading = true;

  final leftTitle = {
    0: 'D5',
    20: 'D10',
    40: 'D15',
    60: 'D20',
    80: 'D25',
    100: 'D30'
  };

  final bottomTitle = {
    0: 'Jan',
    10: 'Feb',
    20: 'Mar',
    30: 'Apr',
    40: 'May',
    50: 'Jun',
    60: 'Jul',
    70: 'Aug',
    80: 'Sep',
    90: 'Oct',
    100: 'Nov',
    110: 'Dec',
  };

  @override
  void initState() {
    super.initState();
    fetchAttendance();
  }

  // Fetch attendance data from the backend
  Future<void> fetchAttendance() async {
    final attendanceProvider = AttendanceProvider();
    try {
      final attendanceData = await attendanceProvider.fetchAttendanceData(
        DateTime.now()
            .subtract(const Duration(days: 30)), // Example range: last 30 days
        DateTime.now(),
      );

      setState(() {
        // Convert attendance data to FlSpot format
        spots = attendanceData.map((data) {
          return FlSpot(
            data['date'].day.toDouble(), // X-axis: day of the month
            data['total_attendance'].toDouble(), // Y-axis: attendance count
          );
        }).toList();
        isLoading = false;
      });
    } catch (error) {
      print('Error fetching attendance data: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Class History",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          AspectRatio(
            aspectRatio: Responsive.isMobile(context) ? 9 / 4 : 16 / 6,
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : LineChart(
                    LineChartData(
                      lineTouchData: const LineTouchData(
                        handleBuiltInTouches: true,
                      ),
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            interval: 1,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              // Format bottom title (X-axis: month)
                              return bottomTitle[value.toInt()] != null
                                  ? SideTitleWidget(
                                      space: 10,
                                      meta: meta,
                                      child: Text(
                                        bottomTitle[value.toInt()].toString(),
                                        style: TextStyle(
                                          fontSize: Responsive.isMobile(context)
                                              ? 9
                                              : 12,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                    )
                                  : const SizedBox();
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            getTitlesWidget: (double value, TitleMeta meta) {
                              // Format left title (Y-axis: attendance count)
                              return leftTitle[value.toInt()] != null
                                  ? Text(
                                      leftTitle[value.toInt()].toString(),
                                      style: TextStyle(
                                        fontSize: Responsive.isMobile(context)
                                            ? 9
                                            : 12,
                                        color: Colors.grey[400],
                                      ),
                                    )
                                  : const SizedBox();
                            },
                            showTitles: true,
                            interval: 1,
                            reservedSize: 40,
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          curveSmoothness: 0,
                          color: Theme.of(context).primaryColor,
                          barWidth: 2.5,
                          isStrokeCapRound: true,
                          belowBarData: BarAreaData(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Theme.of(context).primaryColor.withOpacity(0.5),
                                Colors.transparent
                              ],
                            ),
                            show: true,
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.5),
                          ),
                          dotData: const FlDotData(show: false),
                          spots: spots,
                        ),
                      ],
                      minX: 0,
                      maxX: 120, // Adjust based on your range of days
                      maxY: 105, // Adjust max Y-value if needed
                      minY: -5, // Adjust min Y-value if needed
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
