// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentPlanProvider with ChangeNotifier {
  final String _baseUrl;
  int _lastGeneratedId = 0;

  PaymentPlanProvider() : _baseUrl = dotenv.env['API_BASE_URL']! {
    if (_baseUrl.isEmpty) {
      throw Exception('API base URL is not set. Please check your .env file.');
    }
  }

  bool _isLoading = false;
  List<Map<String, dynamic>> _paymentPlans = [];

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get paymentPlans => _paymentPlans;

  Future<void> createPaymentPlan({
    required String planId,
    required int boxId,
    required int amount,
    required String currency,
    required String token,
    required String description,
  }) async {
    _isLoading = true;
    notifyListeners();

    print('Creating payment plan for Box ID: $boxId'); // Debug print

    final baseUrl = dotenv.env['API_BASE_URL'];
    if (baseUrl == null) {
      throw Exception('Base URL is not configured in the environment.');
    }

    // Generate a unique ID
    final newId = _generateUniqueId();

    final url = Uri.parse('$baseUrl/payment_plans/');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'id': newId, // Include the generated ID
          'plan_id': planId,
          'box_id': boxId,
          'amount': amount,
          'currency': currency,
          'description': description,
        }),
      );

      print(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Payment plan created successfully.'); // Debug print
      } else {
        throw Exception(
            'Failed to create payment plan: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating payment plan: $e'); // Debug print
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Generates a unique, auto-incremented ID
  int _generateUniqueId() {
    _lastGeneratedId++;
    return _lastGeneratedId;
  }

  // Fetch all payment plans
  Future<void> fetchPaymentPlans(String token) async {
    _setLoading(true);

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/payment_plans/'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        _paymentPlans =
            List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        _handleErrorResponse(response);
      }
    } catch (e) {
      print('Error fetching payment plans: $e');
      throw Exception('An error occurred while fetching payment plans: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Create a new payment
  Future<void> createPayment({
    required int userId,
    required int boxId,
    required int amount,
    required String currency,
    required int paymentPlanId,
    required String token,
  }) async {
    _setLoading(true);

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payments/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'user_id': userId,
          'box_id': boxId,
          'amount': amount,
          'currency': currency,
          'payment_plan_id': paymentPlanId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Payment created successfully: ${response.body}');
      } else {
        _handleErrorResponse(response);
      }
    } catch (e) {
      print('Error creating payment: $e');
      throw Exception('An error occurred while creating the payment: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Set the loading state and notify listeners
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Handle non-200/201 error responses
  void _handleErrorResponse(http.Response response) {
    print('Request failed: ${response.statusCode} - ${response.body}');
    throw Exception(
        'Failed request with status code ${response.statusCode}: ${response.body}');
  }
}
