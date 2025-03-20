// ignore_for_file: avoid_print

import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import 'package:flutter/material.dart';
import 'package:wod_book/auth/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';

class UserProvider with ChangeNotifier {
  AuthProvider? _authProvider;
  int? _userId;
  int? _boxId; // Assuming you have a way to get/set boxId
  String? _name;
  String? _lastname;
  String? _profileImageUrl;
  bool _isMembershipActive = false;
  DateTime? _membershipExpiryDate;
  bool _isLoading = false;
  List<UserWithPaymentStatus>? _members; // Updated to use the new model
  String? _email;

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
  String? get lastname => _lastname;
  String? get profileImageUrl => _profileImageUrl;
  bool get isMembershipActive => _isMembershipActive;
  DateTime? get membershipExpiryDate => _membershipExpiryDate;
  List<UserWithPaymentStatus>? get members => _members;
  bool get isLoading => _isLoading;
  String? get email => _email;

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
        final data = json.decode(utf8.decode(response.bodyBytes));
        _userId = data['id']; // Store userId
        _boxId = data['box_id']; // Store boxId if available in the response

        print('User ID: $_userId'); // Debug print
        print('Box ID: $_boxId'); // Debug print
        print('Name: $_name'); // Debug print


        _name = data['first_name'];
        _lastname = data['last_name'];
        _profileImageUrl = data['profile_image'];
        _email = data['email'];
        _boxId = data['box_id'];

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

  // Edit account details
  Future<void> editAccountDetails({
    required String firstName,
    required String lastName,
    required String email,
    String? profileImage,
  }) async {
    if (_isLoading) return;
    _setLoading(true);

    final token = _authProvider?.token;
    if (token == null) {
      _setLoading(false);
      throw Exception('Token not found');
    }

    final athleteId =
        _userId; // Retrieve the current user's ID from the provider
    if (athleteId == null) {
      _setLoading(false);
      throw Exception('User ID not found');
    }

    try {
      final url = Uri.parse(
          '$_baseUrl/admin/athletes/$athleteId'); // Use the current user's ID
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'id': athleteId,
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'profile_image': profileImage, // Optional field
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _name = data['first_name'];
        _profileImageUrl = data['profile_image'];
        notifyListeners();
        fetchUserData();
        print(data);
      } else {
        _handleErrorResponse(response);
      }
    } catch (e) {
      print('Error editing account details: $e');
      throw Exception('An error occurred while editing account details: $e');
    } finally {
      _setLoading(false);
    }
  }

// Delete account
  Future<void> deleteAccount() async {
    if (_isLoading) return;
    _setLoading(true);

    final token = _authProvider?.token;
    if (token == null) {
      _setLoading(false);
      throw Exception('Token not found');
    }

    final athleteId =
        _userId; // Retrieve the current user's ID from the provider
    if (athleteId == null) {
      _setLoading(false);
      throw Exception('User ID not found');
    }

    try {
      final url = Uri.parse(
          '$_baseUrl/athletes/$athleteId'); // Use the current user's ID
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 204) {
        print('Account successfully deleted');
        // Optionally, logout the user and clear local data
        _authProvider?.logout();
      } else {
        _handleErrorResponse(response);
      }
    } catch (e) {
      print('Error deleting account: $e');
      throw Exception('An error occurred while deleting account: $e');
    } finally {
      _setLoading(false);
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
      final url = Uri.parse(
          '$_baseUrl/admin/users/membership-status'); // Adjust URL if needed
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
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

  Future<void> blockUser(int userId) async {
    if (_isLoading) return; // Prevent multiple requests at the same time
    _setLoading(true);

    final token = _authProvider?.token;
    if (token == null) {
      _setLoading(false);
      throw Exception('Token not found');
    }

    try {
      final url = Uri.parse('$_baseUrl/users/block/$userId');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Optionally, update UI or notify the user
        final data = json.decode(response.body);
        print('User $userId blocked successfully: ${data['message']}');
        // You could refresh user data or members after blocking
      } else {
        _handleErrorResponse(response);
      }
    } catch (e) {
      print('Error blocking user: $e');
      throw Exception('An error occurred while blocking user: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Check if a user is blocked based on their ID
  Future<bool> isUserBlocked(int targetUserId) async {
    if (_isLoading) return false; // Prevent multiple simultaneous requests

    final token = _authProvider?.token;
    if (token == null) {
      throw Exception('Token not found');
    }

    try {
      final url = Uri.parse(
          '$_baseUrl/check-block/$targetUserId'); // Endpoint for checking block status
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // If the response is a success and user is not blocked
        return data["message"] == "User is not blocked";
      } else {
        // If the user is blocked, throw an exception
        if (response.statusCode == 403) {
          throw Exception(
              "You have blocked this user. Access to their profile is denied.");
        }
        _handleErrorResponse(response);
        return false;
      }
    } catch (e) {
      print('Error checking block status: $e');
      throw Exception('An error occurred while checking block status: $e');
    }
  }

  Future<void> requestPasswordReset(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/request-password-reset/'),
        body: json.encode({'email': email}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception(
              "Password reset request failed");
        }
        _handleErrorResponse(response);
    } catch (e) {
      print('Error: $e');
      throw Exception('An error occurred: $e');
    }
  }

  Future<String?> uploadImage(File image) async {
    _setLoading(true);  // Show loading spinner during upload
    final mimeType = lookupMimeType(image.path);
    if (mimeType == null) {
      _setLoading(false);  // Hide loading spinner in case of an error
      throw Exception('Cannot determine the MIME type of the image.');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/upload'),
    );

    try {
      request.files.add(
        http.MultipartFile(
          'file',
          image.readAsBytes().asStream(),
          image.lengthSync(),
          filename: path.basename(image.path),
          contentType: MediaType.parse(mimeType),
        ),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final decodedResponse = json.decode(responseData);

        // Validate response data
        if (decodedResponse['url'] == null) {
          _setLoading(false);  // Hide loading spinner
          throw Exception('Failed to parse uploaded image URL from response.');
        }

        return decodedResponse['url'];
      } else {
        _setLoading(false);  // Hide loading spinner
        throw Exception('Failed to upload image: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error uploading image: $e');
      _setLoading(false);  // Hide loading spinner
      throw Exception('An error occurred while uploading image: $e');
    } finally {
      _setLoading(false);  // Hide loading spinner
    }
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/reset-password/'),
        body: json.encode({
          'token': token,
          'new_password': newPassword,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception(
              "Password reset failed");
        }
        _handleErrorResponse(response);
    } catch (e) {
      print('Error: $e');
      throw Exception('An error occurred: $e');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _handleErrorResponse(http.Response response) {
    print('Request failed: ${response.statusCode} - ${response.body}');
    throw Exception(
        'Request failed with status code ${response.statusCode}: ${response.body}');
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
