// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../model/performance_model.dart';

class PerformanceProvider with ChangeNotifier {
  List<Performance> _performances = [];
  List<Performance> _leaderboard = [];

  List<Performance> get performances => _performances;
  List<Performance> get leaderboard => _leaderboard;

  final String _baseUrl;

  PerformanceProvider() : _baseUrl = dotenv.env['API_BASE_URL']! {
    if (_baseUrl.isEmpty) {
      throw Exception('API base URL is not set. Please check your .env file.');
    }
  }

  // Fetch performances from the server
  Future<void> fetchPerformances() async {
    _setLoading(true);

    try {
      final response = await http.get(Uri.parse('$_baseUrl/performances/'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        _performances = data.map((json) => Performance.fromJson(json)).toList();
        notifyListeners();
      } else {
        _handleErrorResponse(response);
      }
    } catch (e) {
      print('Error fetching performances: $e');
      throw Exception('An error occurred while fetching performances: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add a new performance
  Future<void> addPerformance(String category, int weight) async {
    _setLoading(true);

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/performances/'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'category': category,
          'weight': weight,
        }),
      );

      if (response.statusCode == 201) {
        final newPerformance = Performance.fromJson(json.decode(response.body));
        _performances.add(newPerformance);
        notifyListeners();
      } else {
        _handleErrorResponse(response);
      }
    } catch (e) {
      print('Error adding performance: $e');
      throw Exception('An error occurred while adding performance: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Fetch leaderboard from the server
  Future<void> fetchLeaderboard() async {
    _setLoading(true);

    try {
      final response = await http.get(Uri.parse('$_baseUrl/leaderboard/'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        _leaderboard = data.map((json) => Performance.fromJson(json)).toList();
        notifyListeners();
      } else {
        _handleErrorResponse(response);
      }
    } catch (e) {
      print('Error fetching leaderboard: $e');
      throw Exception('An error occurred while fetching the leaderboard: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Set the loading state and notify listeners
  void _setLoading(bool value) {
    // You can define your loading state variable and notify listeners here
    notifyListeners();
  }

  // Handle non-200/201 error responses
  void _handleErrorResponse(http.Response response) {
    print('Request failed: ${response.statusCode} - ${response.body}');
    throw Exception('Failed request with status code ${response.statusCode}: ${response.body}');
  }
}
