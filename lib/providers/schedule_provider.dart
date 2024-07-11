// providers/schedule_provider.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/schedule_model.dart';

class ScheduleProvider with ChangeNotifier {
  List<Schedule> _schedules = [];

  List<Schedule> get schedules => _schedules;

  Future<void> fetchSchedules() async {
    final response = await http.get(Uri.parse('http://your-backend-url/schedules/'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      _schedules = data.map((json) => Schedule.fromJson(json)).toList();
      notifyListeners();
    } else {
      throw Exception('Failed to load schedules');
    }
  }

  Future<void> addSchedule(String title, String description, DateTime startTime, DateTime endTime) async {
    final response = await http.post(
      Uri.parse('http://your-backend-url/schedules/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'title': title,
        'description': description,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
      }),
    );

    if (response.statusCode == 201) {
      final newSchedule = Schedule.fromJson(json.decode(response.body));
      _schedules.add(newSchedule);
      notifyListeners();
    } else {
      throw Exception('Failed to add schedule');
    }
  }
}
