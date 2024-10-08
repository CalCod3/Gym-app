// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import '../dashboard.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'auth_provider.dart';
import 'login_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv for environment variables

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  SignupPageState createState() => SignupPageState();
}

class SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isSubmitting = false;
  
  // Add a variable to store the selected box and the list of available boxes
  String? _selectedBox;
  List<dynamic> _availableBoxes = [];

  @override
  void initState() {
    super.initState();
    _fetchBoxes();  // Fetch available boxes when the page is initialized
  }

  Future<void> _fetchBoxes() async {
    try {
      final String? apiUrl = dotenv.env['API_BASE_URL'];
      if (apiUrl == null) {
        throw Exception('API_BASE_URL not set in .env file');
      }

      final response = await http.get(Uri.parse('$apiUrl/api/boxes/')); // Replace with your actual endpoint for fetching boxes
      if (response.statusCode == 200) {
        setState(() {
          _availableBoxes = json.decode(response.body);
        });
      } else {
        print('Failed to fetch boxes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching boxes: $e');
    }
  }

  Future<void> _signup() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final String? apiUrl = dotenv.env['API_BASE_URL'];

      if (apiUrl == null) {
        throw Exception('API_BASE_URL not set in .env file');
      }

      final response = await http.post(
        Uri.parse('$apiUrl/auth/'), // Replace with your actual endpoint path
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'first_name': _firstNameController.text,
          'last_name': _lastNameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'box_id': _selectedBox, // Pass the selected box ID
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);

        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.login(responseData['access_token']);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DashBoard()),
          );
        }
      } else {
        final responseBody = response.body;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup failed: $responseBody')),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signup'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SizedBox(
                width: 400,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        controller: _firstNameController,
                        decoration:
                            const InputDecoration(labelText: 'First Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your first name';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _lastNameController,
                        decoration:
                            const InputDecoration(labelText: 'Last Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your last name';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _passwordController,
                        decoration:
                            const InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: const InputDecoration(
                            labelText: 'Confirm Password'),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          return null;
                        },
                      ),
                      // Add the DropdownButtonFormField for selecting the box
                      DropdownButtonFormField<String>(
                        value: _selectedBox,
                        hint: const Text('Select Box'),
                        items: _availableBoxes.map<DropdownMenuItem<String>>((box) {
                          return DropdownMenuItem<String>(
                            value: box['id'].toString(),
                            child: Text(box['name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedBox = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a box';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _isSubmitting
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _signup();
                                }
                              },
                              child: const Text('Signup'),
                            ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                          );
                        },
                        child: const Text('Already have an account? Login'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
