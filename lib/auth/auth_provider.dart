import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _token;
  int? _userId;
  bool? _isAdmin;

  String? get token => _token;
  int? get userId => _userId;
  bool? get isAdmin => _isAdmin;

  Future<void> login(String token) async {
    _token = token;
    await _storage.write(key: 'token', value: token);
    await _fetchUserData(); // Fetch user data after storing the token
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _isAdmin = null;
    await _storage.delete(key: 'token');
    notifyListeners();
  }

  Future<void> loadToken() async {
    _token = await _storage.read(key: 'token');
    if (_token != null) {
      await _fetchUserData(); // Fetch user data when loading the token
    }
    notifyListeners();
  }

  Future<void> _fetchUserData() async {
    if (_token == null) return;

    final url = Uri.parse('http://127.0.0.1:8001/users/me');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $_token',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _userId = data['id']; // Assuming the response contains the user ID as 'id'
      _isAdmin = data['is_staff']; // Assuming the response contains the is_staff field as 'is_staff'
    } else {
      throw Exception('Failed to fetch user data: ${response.statusCode}');
    }
  }

  // New method to get the token
  String? getToken() {
    return _token;
  }
}
