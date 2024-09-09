// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import flutter_dotenv

class AuthProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _token;
  int? _userId;
  bool? _isAdmin;
  bool? _isCoach;

  String? get token => _token;
  int? get userId => _userId;
  bool? get isAdmin => _isAdmin;
  bool? get isCoach => _isCoach;

  Future<void> login(String token) async {
    _token = token;
    await _storage.write(key: 'token', value: token);
    try {
      await _fetchUserData(); // Fetch user data after storing the token
    } catch (e) {
      print('Error during login: $e');
      _token = null; // Clear token if user data fetch fails
    }
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _isAdmin = null;
    _isCoach = null;
    await _storage.delete(key: 'token');
    notifyListeners();
  }

  Future<void> loadToken() async {
    _token = await _storage.read(key: 'token');
    if (_token != null) {
      try {
        await _fetchUserData(); // Fetch user data when loading the token
      } catch (e) {
        print('Error loading token and fetching user data: $e');
        _token = null; // Clear token if user data fetch fails
      }
    }
    notifyListeners();
  }

  Future<void> _fetchUserData() async {
    final token = _token;
    final baseUrl = dotenv.env['API_BASE_URL'];

    if (token == null) {
      throw Exception('Cannot fetch user data: Token is not available.');
    }
    if (baseUrl == null) {
      throw Exception('Base URL is not configured in the environment.');
    }

    try {
      final url = Uri.parse('$baseUrl/users/me');
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _userId = data['id']; // Assuming the response contains the user ID as 'id'
        _isAdmin = data['is_staff']; // Assuming the response contains the is_staff field as 'is_staff'
        _isCoach = data['is_coach'];
      } else {
        throw Exception('Failed to fetch user data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user data: $e');
      rethrow; // Rethrow to let the caller handle the error
    }
  }

  // New method to get the token
  String? getToken() {
    return _token;
  }
}
