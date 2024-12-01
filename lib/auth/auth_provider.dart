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
  int? _boxId;
  bool? _isAdmin;
  bool? _isCoach;
  String?  _email;

  String? get token => _token;
  int? get userId => _userId;
  int? get boxId => _boxId;
  bool? get isAdmin => _isAdmin;
  bool? get isCoach => _isCoach;
  String? get email => _email;

  /// Login method to save token and fetch user data.
  Future<void> login(String token) async {
    _token = token;
    await _storage.write(key: 'token', value: token);
    try {
      // Fetch user data after successfully saving the token
      await _fetchUserData();
      notifyListeners();
    } catch (e) {
      print('Error during login: $e');
      _token = null; // Clear token if user data fetch fails
      notifyListeners();
    }
  }

  /// Logout method to clear token and user data.
  Future<void> logout() async {
    _token = null;
    _userId = null;
    _isAdmin = null;
    _isCoach = null;
    await _storage.delete(key: 'token');
    notifyListeners();
  }

  /// Load token from secure storage and attempt auto-login.
  Future<void> loadToken() async {
    _token = await _storage.read(key: 'token');
    if (_token != null) {
      try {
        // Fetch user data when loading the token to auto-login
        await _fetchUserData();
        notifyListeners();
      } catch (e) {
        print('Error loading token and fetching user data: $e');
        await logout(); // Clear token if user data fetch fails
      }
    } else {
      // Clear any previous login state
      logout();
    }
  }

  /// Fetch the logged-in user's data using the saved token.
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
        _isAdmin = data['is_staff']; // Assuming the response contains 'is_staff'
        _isCoach = data['is_coach'];
        _email = data['email']; // Assuming the response contains 'email'
        _boxId = data['bix_id'];
      } else if (response.statusCode == 401) {
        // Token is invalid or expired, handle logout
        await logout();
        throw Exception('Token expired or invalid.');
      } else {
        throw Exception('Failed to fetch user data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user data: $e');
      rethrow; // Rethrow to let the caller handle the error
    }
  }

  /// Optional method to manually retrieve the current token.
  String? getToken() {
    return _token;
  }
}
