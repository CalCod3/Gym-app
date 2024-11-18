// ignore_for_file: avoid_print, library_private_types_in_public_api, unused_field

import 'package:WOD_Book/auth/auth_provider.dart';
import 'package:WOD_Book/model/schedule_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../../providers/schedule_provider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Fetch the data when the calendar screen is accessed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token =
          Provider.of<AuthProvider>(context, listen: false).getToken();
      if (token != null) {
        Provider.of<ScheduleProvider>(context, listen: false)
            .fetchAllCalendarItems(token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = Provider.of<ScheduleProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            firstDay: DateTime(2020),
            lastDay: DateTime(2050),
            calendarFormat: CalendarFormat.month,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              // Fetch data for the selected day
              scheduleProvider.fetchSchedulesForDay(selectedDay);
            },
            onFormatChanged: (CalendarFormat format) {
              setState(() {
                _calendarFormat = format;
              });
              print("Selected Calendar Format: $format");
            },
            eventLoader: (day) {
              return scheduleProvider.schedules
                  .where((schedule) =>
                      isSameDay(schedule.startTime, day) ||
                      isSameDay(schedule.endTime, day))
                  .toList();
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return null;

                final typedEvents = events.cast<Schedule>();

                final scheduleEvents =
                    typedEvents.where((e) => e.type == 'schedule').toList();
                final activityEvents =
                    typedEvents.where((e) => e.type == 'activity').toList();
                final groupWorkoutEvents = typedEvents
                    .where((e) => e.type == 'group_workout')
                    .toList();

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (scheduleEvents.isNotEmpty)
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                        ),
                      ),
                    if (activityEvents.isNotEmpty)
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
                        ),
                      ),
                    if (groupWorkoutEvents.isNotEmpty)
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          // Display selected day's events below the calendar
          Expanded(
            child: ListView(
              children: [
                _buildEventSection(
                  'Scheduled Activities',
                  scheduleProvider,
                  'schedule',
                  _selectedDay, // Pass the selected day here
                ),
                _buildEventSection(
                  'Activities',
                  scheduleProvider,
                  'activity',
                  _selectedDay, // Pass the selected day here
                ),
                _buildEventSection(
                  'Group Workouts',
                  scheduleProvider,
                  'group_workout',
                  _selectedDay, // Pass the selected day here
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEventSection(
    String title,
    ScheduleProvider scheduleProvider,
    String eventType,
    DateTime
        selectedDay, // Add selectedDay to filter events for that specific day
  ) {
    // Fetch events for the selected day using the ScheduleProvider's fetchSchedulesForDay method
    final events = scheduleProvider
        .fetchSchedulesForDay(selectedDay)
        .where((e) => e.type == eventType)
        .toList();

    if (events.isEmpty) {
      // If there are no events for that day, show a message indicating that
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Nothing is scheduled for this day.',
          style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          ...events.map((e) => ListTile(
                title: Text(e.title),
                subtitle: Text(
                  // Format the start and end time for the selected day
                  '${DateFormat('MMM dd, yyyy').format(e.startTime)} - ${DateFormat('h:mm a').format(e.startTime)} to ${DateFormat('h:mm a').format(e.endTime)}',
                  style: TextStyle(fontSize: 12), // Make subtitle smaller
                ),
                tileColor: _getEventColor(eventType),
              )),
        ],
      ),
    );
  }

  Color _getEventColor(String eventType) {
    switch (eventType) {
      case 'schedule':
        return Colors.blue.withOpacity(0.1);
      case 'activity':
        return Colors.green.withOpacity(0.1);
      case 'group_workout':
        return Colors.white.withOpacity(0.1);
      default:
        return Colors.grey.withOpacity(0.1);
    }
  }
}
