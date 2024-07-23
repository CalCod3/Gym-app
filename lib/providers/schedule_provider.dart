// providers/schedule_provider.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/schedule_model.dart';

class ScheduleProvider with ChangeNotifier {
  List<Schedule> _schedules = [];

  List<Schedule> get schedules => _schedules;

  Future<void> fetchSchedules(String token) async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8001/schedules/'),
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
  }

  Future<bool> addSchedule(
    String token,
    String title,
    String description,
    DateTime startTime,
    DateTime endTime,
  ) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8001/schedules/'),
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
}
