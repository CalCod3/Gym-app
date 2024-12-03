// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _nameController = TextEditingController(text: userProvider.name ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Ensure that all necessary fields are provided
                    final userProvider =
                        Provider.of<UserProvider>(context, listen: false);

                    // Collect the values for firstName, lastName, and email
                    final firstName = _nameController.text.split(' ')[
                        0]; // Assuming the first name is the first part of the name
                    final lastName = _nameController.text.split(' ').length > 1
                        ? _nameController.text.split(' ')[1]
                        : ''; // Assuming last name is the second part of the name
                    final email = userProvider.email ??
                        ''; // You may need to retrieve the current email from the provider

                    // Call the editAccountDetails method with the required fields
                    await userProvider.editAccountDetails(
                      firstName: firstName,
                      lastName: lastName,
                      email: email,
                      profileImage:
                          null, // Optional, pass current profile image if needed
                    );

                    // Provide feedback on success
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Profile updated successfully')),
                    );
                    Navigator.pop(context); // Go back to the profile page
                  }
                },
                child: const Text('Save Changes'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () async {
                  final confirmDelete = await _confirmDelete(context);
                  if (confirmDelete) {
                    final secondConfirm = await _confirmDelete(context);
                    if (secondConfirm) {
                      try {
                        await userProvider.deleteAccount();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Account deleted successfully')),
                        );
                        Navigator.of(context).popUntil((route) =>
                            route.isFirst); // Return to the initial screen
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error deleting account: $e')),
                        );
                      }
                    }
                  }
                },
                child: const Text('Delete Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Deletion'),
              content: const Text(
                  'Are you sure you want to delete your account? This action cannot be undone.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
