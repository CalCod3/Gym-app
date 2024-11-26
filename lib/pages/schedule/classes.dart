// screens/add_class_screen.dart

// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/schedule_provider.dart';
import '../../auth/auth_provider.dart';

class AddClassScreen extends StatefulWidget {
  const AddClassScreen({super.key});

  @override
  _AddClassScreenState createState() => _AddClassScreenState();
}

class _AddClassScreenState extends State<AddClassScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  String? _feedbackMessage;
  bool _isSuccess = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final startDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _startTime.hour,
        _startTime.minute,
      );

      final endDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _endTime.hour,
        _endTime.minute,
      );

      final token = Provider.of<AuthProvider>(context, listen: false).getToken();
      if (token != null) {
        setState(() {
          _feedbackMessage = null; // Clear previous feedback
        });

        try {
          final success = await Provider.of<ScheduleProvider>(context, listen: false).addSchedule(
            token,
            _title,
            _description,
            startDateTime,
            endDateTime,
          );

          if (success) {
            setState(() {
              _isSuccess = true;
              _feedbackMessage = 'Class added successfully!';
            });

            // Navigate to dashboard after a short delay
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.popUntil(context, ModalRoute.withName('/dashboard'));
            });
          } else {
            setState(() {
              _isSuccess = false;
              _feedbackMessage =
                  'Failed to add class. Please check your input.';
            });
          }
        } catch (e) {
          setState(() {
            _isSuccess = false;
            _feedbackMessage = 'An error occurred: $e';
          });
        }
      } else {
        setState(() {
          _isSuccess = false;
          _feedbackMessage =
              'Authentication token is missing. Please log in again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Class'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Class Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                onSaved: (value) {
                  _description = value!;
                },
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Text('Date: ${_selectedDate.toLocal()}'.split(' ')[0]),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('Select date'),
                  ),
                ],
              ),
              Row(
                children: [
                  Text('Start Time: ${_startTime.format(context)}'),
                  TextButton(
                    onPressed: () => _selectTime(context, true),
                    child: const Text('Select start time'),
                  ),
                ],
              ),
              Row(
                children: [
                  Text('End Time: ${_endTime.format(context)}'),
                  TextButton(
                    onPressed: () => _selectTime(context, false),
                    child: const Text('Select end time'),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              if (_feedbackMessage != null)
                Text(
                  _feedbackMessage!,
                  style: TextStyle(
                    color: _isSuccess ? Colors.green : Colors.red,
                    fontSize: 16.0,
                  ),
                ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Add Class'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
