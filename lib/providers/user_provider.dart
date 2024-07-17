import 'package:flutter/material.dart';
import 'package:flutter_dashboard/auth/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserProvider with ChangeNotifier {
  final AuthProvider authProvider; // Reference to AuthProvider
  String? _name;
  String? _profileImageUrl;

  UserProvider(this.authProvider);

  String? get name => _name;
  String? get profileImageUrl => _profileImageUrl;

  Future<void> fetchUserData() async {
    final token = authProvider.token; // Retrieve token from AuthProvider
    if (token == null) {
      throw Exception('Token not found'); // Handle case where token is not available
    }

    final url = Uri.parse('http://127.0.0.1:8001/users/me');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token', // Include token in Authorization header
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _name = data['name'];
      _profileImageUrl = data['profile_image_url'];
      notifyListeners();
    } else {
      throw Exception('Failed to load user data: ${response.statusCode}');
    }
  }
}
