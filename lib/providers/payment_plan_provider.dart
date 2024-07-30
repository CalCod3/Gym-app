// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentPlanProvider with ChangeNotifier {
  final String _baseUrl = 'http://127.0.0.1:8001';
  bool _isLoading = false;
  List<Map<String, dynamic>> _paymentPlans = [];

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get paymentPlans => _paymentPlans;

  Future<void> createPaymentPlan(
    String planId,
    int boxId,
    int amount,
    String currency,
    String token,
    String description,
  ) async {
    _isLoading = true;
    notifyListeners();

    final response = await http.post(
      Uri.parse('$_baseUrl/payment_plans/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'plan_id': planId,
        'box_id': boxId,
        'amount': amount,
        'currency': currency,
        'description': description,
      }),
    );

    _isLoading = false;
    notifyListeners();

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Payment plan created successfully: ${response.body}');
      // Fetch the updated list of payment plans after creating a new one
      await fetchPaymentPlans(token);
    } else {
      print('Failed to create payment plan: ${response.body}');
      throw Exception('Failed to create payment plan');
    }
  }

  Future<void> fetchPaymentPlans(String token) async {
    _isLoading = true;
    notifyListeners();

    final response = await http.get(
      Uri.parse('$_baseUrl/payment_plans/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      _paymentPlans = List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      print('Failed to load payment plans: ${response.body}');
      throw Exception('Failed to load payment plans');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createPayment({
    required int userId,
    required int boxId,
    required int amount,
    required String currency,
    required int paymentPlanId,
    required String token,
  }) async {
    _isLoading = true;
    notifyListeners();

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

    _isLoading = false;
    notifyListeners();

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Payment created successfully: ${response.body}');
    } else {
      print('Failed to create payment: ${response.body}');
      throw Exception('Failed to create payment');
    }
  }
}
