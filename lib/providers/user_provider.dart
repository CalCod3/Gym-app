// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:fit_nivel/auth/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  UserProvider(this._authProvider) {
    if (dotenv.env['API_BASE_URL'] == null) {
      throw Exception('API base URL is not set. Please check your .env file.');
    }
  }

  final String _baseUrl = dotenv.env['API_BASE_URL']!;

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
    _setLoading(true);

    final token = _authProvider?.token;

    if (token == null) {
      _setLoading(false);
      throw Exception('Token not found');
    }

    try {
      final url = Uri.parse('$_baseUrl/users/me');
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
      } else {
        _handleErrorResponse(response);
      }
    } catch (e) {
      print('Error fetching user data: $e'); // Debug print
      throw Exception('An error occurred while fetching user data: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchPaymentInfo(String token) async {
    final url = Uri.parse('$_baseUrl/payments/');
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
        _handleErrorResponse(response);
      }
    } catch (e) {
      print('Error fetching payment info: $e'); // Debug print
      throw Exception('An error occurred while fetching payment info: $e');
    }
  }

  Future<void> fetchMembers() async {
    if (_isLoading) return;
    _setLoading(true);

    final token = _authProvider?.token;
    final isAdmin = _authProvider?.isAdmin ?? false;

    if (token == null || !isAdmin) {
      _setLoading(false);
      throw Exception('Unauthorized or Token not found');
    }

    try {
      final url = Uri.parse('$_baseUrl/admin/users/membership-status'); // Adjust URL if needed
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _members = (data as List)
            .map((item) => UserWithPaymentStatus.fromJson(item))
            .toList();
        notifyListeners();
      } else {
        _handleErrorResponse(response);
      }
    } catch (e) {
      print('Error fetching members: $e'); // Debug print
      throw Exception('An error occurred while fetching members: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _handleErrorResponse(http.Response response) {
    print('Request failed: ${response.statusCode} - ${response.body}');
    throw Exception('Request failed with status code ${response.statusCode}: ${response.body}');
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
