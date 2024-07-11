// providers/performance_provider.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/performance_model.dart';

class PerformanceProvider with ChangeNotifier {
  List<Performance> _performances = [];
  List<Performance> _leaderboard = [];

  List<Performance> get performances => _performances;
  List<Performance> get leaderboard => _leaderboard;

  Future<void> fetchPerformances() async {
    final response = await http.get(Uri.parse('http://your-backend-url/performances/'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      _performances = data.map((json) => Performance.fromJson(json)).toList();
      notifyListeners();
    } else {
      throw Exception('Failed to load performances');
    }
  }

  Future<void> addPerformance(String category, int weight) async {
    final response = await http.post(
      Uri.parse('http://your-backend-url/performances/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'category': category,
        'weight': weight,
      }),
    );

    if (response.statusCode == 201) {
      final newPerformance = Performance.fromJson(json.decode(response.body));
      _performances.add(newPerformance);
      notifyListeners();
    } else {
      throw Exception('Failed to add performance');
    }
  }

  Future<void> fetchLeaderboard() async {
    final response = await http.get(Uri.parse('http://your-backend-url/leaderboard/'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      _leaderboard = data.map((json) => Performance.fromJson(json)).toList();
      notifyListeners();
    } else {
      throw Exception('Failed to load leaderboard');
    }
  }
}
