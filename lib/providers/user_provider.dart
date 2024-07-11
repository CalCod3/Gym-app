import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserProvider with ChangeNotifier {
  String? _name;
  String? _profileImageUrl;

  String? get name => _name;
  String? get profileImageUrl => _profileImageUrl;

  Future<void> fetchUserData() async {
    final url = Uri.parse('https://your-fastapi-endpoint.com/user/profile');
    // Add your token if necessary
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer your_token_here',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _name = data['name'];
      _profileImageUrl = data['profile_image_url'];
      notifyListeners();
    } else {
      throw Exception('Failed to load user data');
    }
  }
}
