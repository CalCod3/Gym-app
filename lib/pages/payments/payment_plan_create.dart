// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/payment_plan_provider.dart';
import '../../auth/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../pages/home/home_page.dart';

class CreatePaymentPlanPage extends StatefulWidget {
  const CreatePaymentPlanPage({super.key});

  @override
  _CreatePaymentPlanPageState createState() => _CreatePaymentPlanPageState();
}

class _CreatePaymentPlanPageState extends State<CreatePaymentPlanPage> {
  final _formKey = GlobalKey<FormState>();
  String _planId = '';
  int _amount = 0;
  String _currency = 'USD';
  String _description = '';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final paymentPlanProvider = Provider.of<PaymentPlanProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    // Ensure boxId and token are available
    final int? boxId = userProvider.boxId;
    final String? token = authProvider.token;

    if (boxId == null || token == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Create Payment Plan'),
        ),
        body: const Center(
          child: Text('Unable to retrieve necessary information.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Payment Plan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Plan ID'),
                onSaved: (value) {
                  _planId = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a plan ID';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (value) {
                  _description = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _amount = int.tryParse(value ?? '') ?? 0;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
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
                onPressed: paymentPlanProvider.isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          try {
                            await paymentPlanProvider.createPaymentPlan(
                              _planId,
                              boxId,
                              _amount,
                              _currency,
                              token,
                              _description,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Payment plan created successfully'),
                              ),
                            );
                            // Navigate back to the dashboard
                            Navigator.of(context).pop();
                          } catch (error) {
                            // Handle the error if needed
                          }
                        }
                      },
                child: paymentPlanProvider.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Create Payment Plan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
