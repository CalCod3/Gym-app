// providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _token;
  int? _userId;

  String? get token => _token;
  int? get userId => _userId;

  Future<void> login(String token) async {
    _token = token;
    await _storage.write(key: 'token', value: token);
    await _fetchUserId(); // Fetch user ID after storing the token
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    await _storage.delete(key: 'token');
    notifyListeners();
  }

  Future<void> loadToken() async {
    _token = await _storage.read(key: 'token');
    if (_token != null) {
      await _fetchUserId(); // Fetch user ID when loading the token
    }
    notifyListeners();
  }

  Future<void> _fetchUserId() async {
    if (_token == null) return;

    final url = Uri.parse('http://127.0.0.1:8001/users/me');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $_token',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _userId = data['id']; // Assuming the response contains the user ID as 'id'
    } else {
      throw Exception('Failed to fetch user ID: ${response.statusCode}');
    }
  }

  // New method to get the token
  String? getToken() {
    return _token;
  }
}
