// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_dashboard/auth/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserProvider with ChangeNotifier {
  AuthProvider? _authProvider;
  int? _userId;
  int? _boxId; // Assuming you have a way to get/set boxId
  String? _name;
  String? _profileImageUrl;
  bool _isMembershipActive = false;
  DateTime? _membershipExpiryDate;
  bool _isLoading = false;

  UserProvider(this._authProvider);

  void updateAuthProvider(AuthProvider authProvider) {
    _authProvider = authProvider;
    notifyListeners();
  }

  AuthProvider? get authProvider => _authProvider;
  int? get userId => _userId;
  int? get boxId => _boxId; // Getter for boxId
  String? get name => _name;
  String? get profileImageUrl => _profileImageUrl;
  bool get isMembershipActive => _isMembershipActive;
  DateTime? get membershipExpiryDate => _membershipExpiryDate;

  Future<void> fetchUserData() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    final token = _authProvider?.token;

    if (token == null) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Token not found');
    }

    try {
      final url = Uri.parse('http://127.0.0.1:8001/users/me');
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _userId = data['id']; // Store userId
        _boxId = data['box_id']; // Store boxId if available in the response
        _name = data['first_name'];
        _profileImageUrl = data['profile_image'];

        await fetchPaymentInfo(token);
        _isLoading = false;
        notifyListeners();
      } else {
        _isLoading = false;
        notifyListeners();
        throw Exception('Failed to load user data: ${response.statusCode}');
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('An error occurred: $e');
    }
  }

  Future<void> fetchPaymentInfo(String token) async {
    final url = Uri.parse('http://127.0.0.1:8001/payments/');
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Payment Data: $data'); // Debug print

        if (data != null && data.isNotEmpty) {
          final lastPayment = data.last;
          final paymentDate = DateTime.parse(lastPayment['created_at']);
          final paymentStatus = lastPayment['status'];

          _membershipExpiryDate = paymentDate.add(const Duration(days: 30));
          _isMembershipActive = paymentStatus == 'successful' &&
              _membershipExpiryDate!.isAfter(DateTime.now());
        } else {
          _isMembershipActive = false;
          _membershipExpiryDate = null;
        }
      } else {
        throw Exception('Failed to load payment data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching payment info: $e'); // Debug print
      throw Exception('An error occurred: $e');
    }
  }
}
