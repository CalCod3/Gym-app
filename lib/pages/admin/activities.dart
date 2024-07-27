// screens/activity_list_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/activity_model.dart';
import '../../providers/activity_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';


class ActivityListScreen extends StatelessWidget {
  const ActivityListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final activityProvider = Provider.of<ActivityProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activities'),
      ),
      body: activityProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: activityProvider.activities.length,
              itemBuilder: (ctx, i) {
                final activity = activityProvider.activities[i];
                return ListTile(
                  leading: Image.network(
                    activity.image,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(activity.value),
                  subtitle: Text(activity.title),
                  onTap: () {
                    // Navigate to activity detail screen if needed
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ActivityCreateScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}


class ActivityCreateScreen extends StatefulWidget {
  const ActivityCreateScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ActivityCreateScreenState createState() => _ActivityCreateScreenState();
}

class _ActivityCreateScreenState extends State<ActivityCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _image;
  final _valueController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _image != null) {
      // First, upload the image
      final imageUrl = await Provider.of<ActivityProvider>(context, listen: false).uploadImage(_image!);

      // ignore: duplicate_ignore
      if (imageUrl != null) {
        // Then, create the activity with the image URL
        final newActivity = ActivityModel(
          image: imageUrl,
          value: _valueController.text,
          title: _titleController.text,
          description: _descriptionController.text,
        );

        await Provider.of<ActivityProvider>(context, listen: false).createActivity(newActivity);
        Navigator.of(context).pop();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete the form and pick an image.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Activity'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              GestureDetector(
                onTap: _pickImage,
                child: _image == null
                    ? const Placeholder(fallbackHeight: 200, fallbackWidth: double.infinity)
                    : Image.file(_image!, height: 200, width: double.infinity, fit: BoxFit.cover),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _valueController,
                decoration: const InputDecoration(labelText: 'Value'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a value';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Create Activity'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
