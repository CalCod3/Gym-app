import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/schedule_model.dart';
import '../model/group_workout_model.dart';

class ScheduleProvider with ChangeNotifier {
  List<Schedule> _schedules = [];

  List<Schedule> get schedules => _schedules;

  Future<void> fetchSchedules(String token) async {
    final response = await http.get(
      Uri.parse('https://fitnivel-eba221a3a423.herokuapp.com/schedules/'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      _schedules = data.map((json) => Schedule.fromJson(json)).toList();
      notifyListeners();
    } else {
      throw Exception('Failed to load schedules');
    }

    // Fetch group workouts and add to schedules
    await fetchGroupWorkouts(token);
  }

  Future<void> fetchGroupWorkouts(String token) async {
    final response = await http.get(
      Uri.parse('https://fitnivel-eba221a3a423.herokuapp.com/group_workouts/'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<GroupWorkout> groupWorkouts = data.map((json) => GroupWorkout.fromJson(json)).toList();
      _schedules.addAll(groupWorkouts.map((gw) => Schedule(
        id: gw.id,
        title: gw.name,
        description: gw.description,
        startTime: gw.date,
        endTime: gw.date, // Assuming the end time is the same as the start time for simplicity
      )));
      notifyListeners();
    } else {
      throw Exception('Failed to load group workouts');
    }
  }

  Future<bool> addSchedule(
    String token,
    String title,
    String description,
    DateTime startTime,
    DateTime endTime,
  ) async {
    final response = await http.post(
      Uri.parse('https://fitnivel-eba221a3a423.herokuapp.com/schedules/'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
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
      return false;
    }
  }

  Future<bool> createAndAddGroupWorkout(
    String token,
    String name,
    String description,
    DateTime date,
    List<String> videoLinks,
  ) async {
    final response = await http.post(
      Uri.parse('https://fitnivel-eba221a3a423.herokuapp.com/group_workouts/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'name': name,
        'description': description,
        'date': date.toIso8601String(),
        'video_links': videoLinks,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final newGroupWorkout = GroupWorkout.fromJson(json.decode(response.body));
      addGroupWorkoutToSchedule(newGroupWorkout);
      return true;
    } else {
      return false;
    }
  }

  void addGroupWorkoutToSchedule(GroupWorkout groupWorkout) {
    _schedules.add(Schedule(
      id: groupWorkout.id,
      title: groupWorkout.name,
      description: groupWorkout.description,
      startTime: groupWorkout.date,
      endTime: groupWorkout.date, // Assuming end time is the same as start time for simplicity
    ));
    notifyListeners();
  }
}
