// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';
import '../../widgets/profile/profile.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  late int _amount;
  String _currency = 'USD';
  bool _isLoading = false;

  Future<void> _makePayment() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse('http://your-api-url/payments/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authProvider.token}',
      },
      body: json.encode({
        'amount': _amount,
        'currency': _currency,
      }),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      final payment = json.decode(response.body);
      print('Payment successful: $payment');
      _showSnackBar('Payment successful!');
      _navigateToProfile();
    } else {
      print('Payment failed: ${response.body}');
      final errorDetail = json.decode(response.body)['detail'];
      _showSnackBar('Payment failed: $errorDetail');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _navigateToProfile() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const Profile()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Make Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _amount = int.parse(value!);
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter an amount';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Currency'),
                value: _currency,
                onChanged: (value) {
                  setState(() {
                    _currency = value!;
                  });
                },
                items: ['USD', 'EUR'].map((String currency) {
                  return DropdownMenuItem<String>(
                    value: currency,
                    child: Text(currency),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _makePayment();
                  }
                },
                child: _isLoading ? const CircularProgressIndicator() : const Text('Make Payment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}