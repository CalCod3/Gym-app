// providers/workout_provider.dart
// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import flutter_dotenv
import '../auth/auth_provider.dart';
import 'schedule_provider.dart'; // Import ScheduleProvider

class GroupWorkoutProvider with ChangeNotifier {
  String _title = '';
  String _description = '';
  DateTime? _date;
  final List<String> _videoLinks = [''];

  List<GroupWorkout> _groupWorkouts = [];

  String get title => _title;
  String get description => _description;
  DateTime? get date => _date;
  List<String> get videoLinks => _videoLinks;
  List<GroupWorkout> get groupWorkouts => _groupWorkouts;

  void setTitle(String value) {
    _title = value;
    notifyListeners();
  }

  void setDescription(String value) {
    _description = value;
    notifyListeners();
  }

  void setDate(DateTime value) {
    _date = value;
    notifyListeners();
  }

  void addVideoLink() {
    _videoLinks.add('');
    notifyListeners();
  }

  void updateVideoLink(int index, String value) {
    if (index >= 0 && index < _videoLinks.length) {
      _videoLinks[index] = value;
      notifyListeners();
    }
  }

  void removeVideoLink(int index) {
    if (index >= 0 && index < _videoLinks.length) {
      _videoLinks.removeAt(index);
      notifyListeners();
    }
  }

  bool isValid() {
    return _title.isNotEmpty &&
        _description.isNotEmpty &&
        _date != null;
  }

  Future<void> fetchGroupWorkouts(BuildContext context) async {
    final token = Provider.of<AuthProvider>(context, listen: false).getToken();
    final baseUrl = dotenv.env['API_BASE_URL'];

    if (token == null) {
      throw Exception('Authentication token is not available.');
    }
    if (baseUrl == null) {
      throw Exception('Base URL is not configured in the environment.');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/group_workouts/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _groupWorkouts = data.map((json) => GroupWorkout.fromJson(json)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load group workouts: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching group workouts: $e');
      rethrow; // Rethrow to let the caller handle the error
    }
  }

  Future<bool> createGroupWorkout(BuildContext context) async {
    final token = Provider.of<AuthProvider>(context, listen: false).getToken();
    final baseUrl = dotenv.env['API_BASE_URL'];

    if (token == null) {
      throw Exception('Authentication token is not available.');
    }
    if (baseUrl == null) {
      throw Exception('Base URL is not configured in the environment.');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/group_workouts/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'title': _title,
          'description': _description,
          'date': _date?.toIso8601String(),
          'video_links': _videoLinks.isNotEmpty ? _videoLinks : [],
        }),
      );

      if (response.statusCode == 201) {
        // Successfully created
        GroupWorkout groupWorkout = GroupWorkout.fromJson(json.decode(response.body));
        Provider.of<ScheduleProvider>(context, listen: false).createAndAddGroupWorkout(
          token,
          groupWorkout.title,
          groupWorkout.description,
          groupWorkout.date,
          groupWorkout.videoLinks,
        );
        await fetchGroupWorkouts(context); // Refresh the list
        return true;
      } else {
        throw Exception('Failed to create group workout: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating group workout: $e');
      return false; // Return false to indicate failure
    }
  }
}

class GroupWorkout {
  final int id;
  final String title;
  final String description;
  final DateTime date;
  final List<String> videoLinks;

  GroupWorkout({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.videoLinks,
  });

  factory GroupWorkout.fromJson(Map<String, dynamic> json) {
    return GroupWorkout(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      videoLinks: List<String>.from(json['video_links'] ?? []),
    );
  }
}
