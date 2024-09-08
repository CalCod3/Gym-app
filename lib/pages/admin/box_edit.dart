// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';  // Add this import for image picking
import 'dart:io';  // Add this for file handling
import '../../providers/box_provider.dart';

class EditBoxScreen extends StatefulWidget {
  final String boxId;

  const EditBoxScreen({super.key, required this.boxId});

  @override
  _EditBoxScreenState createState() => _EditBoxScreenState();
}

class _EditBoxScreenState extends State<EditBoxScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _boxName;
  File? _selectedImage;  // Variable to store the selected image
  String? _currentImageUrl;  // To store the current profile image URL

  @override
  void initState() {
    super.initState();
    final boxDetails = Provider.of<BoxProvider>(context, listen: false).boxDetails;
    _boxName = boxDetails['name'];
    _currentImageUrl = boxDetails['profile_image_url'];
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedData = {'name': _boxName};

      if (_selectedImage != null) {
        // If a new image is selected, upload it
        Provider.of<BoxProvider>(context, listen: false)
            .updateBoxDetailsWithImage(widget.boxId, updatedData, _selectedImage!)
            .then((_) {
          Navigator.of(context).pop();
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Error updating box'),
          ));
        });
      } else {
        // If no new image, just update the box details
        Provider.of<BoxProvider>(context, listen: false)
            .updateBoxDetails(widget.boxId, updatedData)
            .then((_) {
          Navigator.of(context).pop();
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Error updating box'),
          ));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Box'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_currentImageUrl != null && _selectedImage == null)
                Center(
                  child: Image.network(
                    _currentImageUrl!,
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image, size: 150),
                  ),
                )
              else if (_selectedImage != null)
                Center(
                  child: Image.file(
                    _selectedImage!,
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                )
              else
                const Center(
                  child: Icon(Icons.image_not_supported, size: 150),
                ),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Change Profile Image'),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                initialValue: _boxName,
                decoration: const InputDecoration(labelText: 'Box Name'),
                textInputAction: TextInputAction.done,
                onSaved: (value) {
                  _boxName = value;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please provide a name';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
