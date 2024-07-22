import 'package:flutter/material.dart';
import 'package:flutter_dashboard/auth/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserProvider with ChangeNotifier {
  AuthProvider? _authProvider; // Reference to AuthProvider
  String? _name;
  String? _profileImageUrl;
  bool _isMembershipActive = false;
  DateTime? _membershipExpiryDate;

  UserProvider(this._authProvider);

  void updateAuthProvider(AuthProvider authProvider) {
    _authProvider = authProvider;
    notifyListeners();
  }

  AuthProvider? get authProvider => _authProvider;
  String? get name => _name;
  String? get profileImageUrl => _profileImageUrl;
  bool get isMembershipActive => _isMembershipActive;
  DateTime? get membershipExpiryDate => _membershipExpiryDate;

  Future<void> fetchUserData() async {
    final token = _authProvider?.token; // Retrieve token from AuthProvider
    if (token == null) {
      throw Exception('Token not found'); // Handle case where token is not available
    }

    final url = Uri.parse('http://127.0.0.1:8001/users/me');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token', // Include token in Authorization header
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _name = data['first_name'];
      _profileImageUrl = data['profile_image_url'];

      // Fetch payment information
      await fetchPaymentInfo(token);
      notifyListeners();
    } else {
      throw Exception('Failed to load user data: ${response.statusCode}');
    }
  }

  Future<void> fetchPaymentInfo(String token) async {
    final url = Uri.parse('http://127.0.0.1:8001/payments/me');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token', // Include token in Authorization header
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        final lastPayment = data.last;
        final paymentDate = DateTime.parse(lastPayment['created_at']);
        final paymentStatus = lastPayment['status'];

        // Assuming monthly payment plan
        _membershipExpiryDate = paymentDate.add(const Duration(days: 30));
        _isMembershipActive = paymentStatus == 'successful' && _membershipExpiryDate!.isAfter(DateTime.now());
      } else {
        _isMembershipActive = false;
        _membershipExpiryDate = null;
      }
    } else {
      throw Exception('Failed to load payment data: ${response.statusCode}');
    }
  }
}
