// ignore_for_file: use_build_context_synchronously


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';
import '../../providers/payment_plan_provider.dart';

class PaymentDetailsPage extends StatefulWidget {
  final Map<String, dynamic> plan;

  const PaymentDetailsPage({super.key, required this.plan});

  @override
  // ignore: library_private_types_in_public_api
  _PaymentDetailsPageState createState() => _PaymentDetailsPageState();
}

class _PaymentDetailsPageState extends State<PaymentDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  late int _amount;
  String _currency = 'USD';
  bool _isLoading = false;

  Future<void> _makePayment() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final paymentPlanProvider = Provider.of<PaymentPlanProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
    });

    try {
      await paymentPlanProvider.createPayment(
        userId: authProvider.userId!,
        boxId: widget.plan['box_id'],
        amount: _amount,
        currency: _currency,
        paymentPlanId: widget.plan['id'], // Ensure you have 'id' in the plan map
        token: authProvider.token!,
      );

      _showSnackBar('Payment successful!');
      Navigator.of(context).pop();
    } catch (e) {
      _showSnackBar('Payment failed: $e');
      // ignore: avoid_print
      print(widget.plan);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment for ${widget.plan['plan_id']}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                initialValue: widget.plan['amount'].toString(),
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
                onPressed: _isLoading
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          _makePayment();
                        }
                      },
                child:
                    _isLoading ? const CircularProgressIndicator() : const Text('Make Payment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
