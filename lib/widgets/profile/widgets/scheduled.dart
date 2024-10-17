import 'package:flutter/material.dart';
import 'package:WOD_Book/widgets/custom_card.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../../providers/schedule_provider.dart';
import '../../../pages/schedule/schedule.dart';

class Scheduled extends StatelessWidget {
  const Scheduled({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Scheduled",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Consumer<ScheduleProvider>(
          builder: (context, scheduleProvider, child) {
            // Sort schedules by start time in ascending order
            final schedules = scheduleProvider.schedules
                .where((schedule) => schedule.startTime.isAfter(DateTime.now()))
                .toList()
              ..sort((a, b) => a.startTime.compareTo(b.startTime));

            // Limit to three items
            final limitedSchedules = schedules.take(3).toList();

            return Column(
              children: [
                for (var schedule in limitedSchedules)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: CustomCard(
                      color: Colors.black,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    schedule.title,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${schedule.startTime} - ${schedule.endTime}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              SvgPicture.asset('assets/svg/more.svg'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                if (schedules.length > 3)
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ScheduleScreen()),
                      );
                    },
                    child: const Text("More"),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
