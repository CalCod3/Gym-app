// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../model/schedule_model.dart';
import '../model/group_workout_model.dart';

class ScheduleProvider with ChangeNotifier {
  List<Schedule> _schedules = [];

  List<Schedule> get schedules => _schedules;

  final String _baseUrl;

  ScheduleProvider() : _baseUrl = dotenv.env['API_BASE_URL']! {
    if (_baseUrl.isEmpty) {
      throw Exception('API base URL is not set. Please check your .env file.');
    }
  }

  Future<void> fetchAllCalendarItems(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/calendar_data/'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        _schedules = data.map((json) {
          String type = json['type'];
          return Schedule(
            id: json['id'],
            title: json['title'],
            description: json['description'],
            startTime: DateTime.parse(json['start_time']),
            endTime: DateTime.parse(json['end_time']),
            type: type,
          );
        }).toList();

        notifyListeners();
      } else {
        _handleErrorResponse(response);
      }
    } catch (e) {
      print('Error fetching calendar items: $e');
      throw Exception('An error occurred while fetching calendar items.');
    }
  }

  List<Schedule> fetchSchedulesForDay(DateTime day) {
    return _schedules.where((schedule) {
      // Check if the schedule's start date is the same as the desired day
      final scheduleDay = DateTime(schedule.startTime.year, schedule.startTime.month, schedule.startTime.day);
      final targetDay = DateTime(day.year, day.month, day.day);
      return scheduleDay.isAtSameMomentAs(targetDay);
    }).toList();
  }
  
  // Fetch schedules from the server
  // Future<void> fetchSchedules(String token) async {
  //   _setLoading(true);

  //   try {
  //     final response = await http.get(
  //       Uri.parse('$_baseUrl/schedules/'),
  //       headers: {
  //         'Content-Type': 'application/json; charset=UTF-8',
  //         'Authorization': 'Bearer $token',
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       List<dynamic> data = json.decode(response.body);
  //       _schedules = data.map((json) => Schedule.fromJson(json)).toList();
  //       notifyListeners();
  //     } else {
  //       _handleErrorResponse(response);
  //     }

  //     // Fetch group workouts and add to schedules
  //     await fetchGroupWorkouts(token);
  //   } catch (e) {
  //     print('Error fetching schedules: $e');
  //     throw Exception('An error occurred while fetching schedules: $e');
  //   } finally {
  //     _setLoading(false);
  //   }
  // }

  // Fetch group workouts from the server
  Future<void> fetchGroupWorkouts(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/group_workouts/'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<GroupWorkout> groupWorkouts =
            data.map((json) => GroupWorkout.fromJson(json)).toList();
        _schedules.addAll(groupWorkouts.map((gw) => Schedule(
              id: gw.id,
              title: gw.name,
              description: gw.description,
              startTime: gw.date,
              endTime: gw.date,
              type: gw
                  .type, // Assuming the end time is the same as the start time for simplicity
            )));
        notifyListeners();
      } else {
        _handleErrorResponse(response);
      }
    } catch (e) {
      print('Error fetching group workouts: $e');
      throw Exception('An error occurred while fetching group workouts: $e');
    }
  }

  // Add a new schedule
  Future<bool> addSchedule(
    String token,
    String title,
    String description,
    DateTime startTime,
    DateTime endTime,
  ) async {
    _setLoading(true);

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/schedules/'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'start_time': startTime.toIso8601String(),
          'end_time': endTime.toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final newSchedule = Schedule.fromJson(json.decode(response.body));
        _schedules.add(newSchedule);
        notifyListeners();
        return true;
      } else {
        _handleErrorResponse(response);
        return false;
      }
    } catch (e) {
      print('Error adding schedule: $e');
      throw Exception('An error occurred while adding schedule: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Create and add a new group workout
  Future<bool> createAndAddGroupWorkout(
    String token,
    String name,
    String description,
    DateTime date,
    List<String> videoLinks,
  ) async {
    _setLoading(true);

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/group_workouts/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'description': description,
          'date': date.toIso8601String(),
          'video_links': videoLinks,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final newGroupWorkout =
            GroupWorkout.fromJson(json.decode(response.body));
        addGroupWorkoutToSchedule(newGroupWorkout);
        return true;
      } else {
        _handleErrorResponse(response);
        return false;
      }
    } catch (e) {
      print('Error creating group workout: $e');
      throw Exception('An error occurred while creating group workout: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add a group workout to the schedule list
  void addGroupWorkoutToSchedule(GroupWorkout groupWorkout) {
    _schedules.add(Schedule(
      id: groupWorkout.id,
      title: groupWorkout.name,
      description: groupWorkout.description,
      startTime: groupWorkout.date,
      endTime: groupWorkout.date,
      type: groupWorkout
          .type, // Assuming end time is the same as start time for simplicity
    ));
    notifyListeners();
  }

  // Set the loading state
  void _setLoading(bool value) {
    // Define your loading state variable and notify listeners if needed
    notifyListeners();
  }

  // Handle non-200/201 error responses
  void _handleErrorResponse(http.Response response) {
    print('Request failed: ${response.statusCode} - ${response.body}');
    throw Exception(
        'Failed request with status code ${response.statusCode}: ${response.body}');
  }
}
