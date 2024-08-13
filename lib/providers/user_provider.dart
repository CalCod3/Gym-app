// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:fit_nivel/auth/auth_provider.dart';
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
  List<UserWithPaymentStatus>? _members; // Updated to use the new model

  UserProvider(this._authProvider);

  void updateAuthProvider(AuthProvider authProvider) {
    _authProvider = authProvider;
    notifyListeners();
  }

  AuthProvider? get authProvider => _authProvider;
  int? get userId => _userId;
  int? get boxId => _boxId;
  String? get name => _name;
  String? get profileImageUrl => _profileImageUrl;
  bool get isMembershipActive => _isMembershipActive;
  DateTime? get membershipExpiryDate => _membershipExpiryDate;
  List<UserWithPaymentStatus>? get members => _members;
  bool get isLoading => _isLoading;

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
      final url = Uri.parse('https://fitnivel-eba221a3a423.herokuapp.com/users/me');
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
    final url = Uri.parse('https://fitnivel-eba221a3a423.herokuapp.com/payments/');
    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Payment Data: $data'); // Debug print

        if (data is List && data.isNotEmpty) {
          final lastPayment = data.last;
          final paymentDate = DateTime.parse(lastPayment['created_at']);
          final paymentStatus = lastPayment['status'];

          _membershipExpiryDate = paymentDate.add(const Duration(days: 30));
          _isMembershipActive = paymentStatus == 'completed' &&
              _membershipExpiryDate!.isAfter(DateTime.now());
        } else {
          _isMembershipActive = false;
          _membershipExpiryDate = null;
        }
        notifyListeners();
      } else {
        throw Exception('Failed to load payment data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching payment info: $e'); // Debug print
      throw Exception('An error occurred: $e');
    }
  }


  Future<void> fetchMembers() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    final token = _authProvider?.token;
    final isAdmin = _authProvider?.isAdmin ?? false;

    if (token == null || !isAdmin) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Unauthorized or Token not found');
    }

    try {
      final url = Uri.parse('https://fitnivel-eba221a3a423.herokuapp.com/admin/users/membership-status'); // Adjust URL if needed
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _members = (data as List)
            .map((item) => UserWithPaymentStatus.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to load members: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final bool isStaff;
  final String? profileImage;
  final int? boxId;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.isStaff,
    this.profileImage,
    this.boxId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      isStaff: json['is_staff'],
      profileImage: json['profile_image'],
      boxId: json['box_id'],
    );
  }
}

class UserWithPaymentStatus {
  final User user;
  final bool hasPaid;

  UserWithPaymentStatus({
    required this.user,
    required this.hasPaid,
  });

  factory UserWithPaymentStatus.fromJson(Map<String, dynamic> json) {
    return UserWithPaymentStatus(
      user: User.fromJson(json['user']),
      hasPaid: json['has_paid'],
    );
  }
}
