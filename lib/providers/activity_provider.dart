// ignore_for_file: avoid_print

import 'package:http_parser/http_parser.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../model/activity_model.dart';

class ActivityProvider with ChangeNotifier {
  List<ActivityModel> _activities = [];
  bool _isLoading = false;

  List<ActivityModel> get activities => _activities;
  bool get isLoading => _isLoading;

  final String _baseUrl;

  ActivityProvider() : _baseUrl = dotenv.env['API_BASE_URL'] ?? '' {
    if (_baseUrl.isEmpty) {
      throw Exception('API base URL is not set. Check your .env file.');
    }
  }

  Future<void> fetchActivities() async {
    _setLoading(true);  // Show loading spinner

    try {
      final response = await http.get(Uri.parse('$_baseUrl/activities/'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Validate the data format
        if (data.isEmpty) {
          throw Exception('Invalid data format received.');
        }

        // Convert and assign activities
        _activities = data.map((json) => ActivityModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load activities: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching activities: $e');
      throw Exception('An error occurred: $e');
    } finally {
      _setLoading(false);  // Hide loading spinner
    }
  }

  Future<void> createActivity(ActivityModel activity, File image) async {
  _setLoading(true); // Show loading spinner

  try {
    // Step 1: Upload the image and get the image URL
    String? imageUrl = await uploadImage(image);
    
    if (imageUrl == null) {
      throw Exception('Failed to upload image.');
    }

    // Step 2: Include the image URL in the activity model
    activity.image = imageUrl;

    // Step 3: Create the activity with the image URL
    final response = await http.post(
      Uri.parse('$_baseUrl/admin/activities/new'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(activity.toJson()),  // Include image URL in the activity data
    );

    if (response.statusCode == 201) {
      await fetchActivities();  // Refresh activities after creation
    } else {
      throw Exception('Failed to create activity: ${response.reasonPhrase}');
    }
  } catch (e) {
    print('Error creating activity: $e');
    throw Exception('An error occurred while creating activity: $e');
  } finally {
    _setLoading(false); // Hide loading spinner
  }
}


  Future<String?> uploadImage(File image) async {
    _setLoading(true);  // Show loading spinner during upload
    final mimeType = lookupMimeType(image.path);
    if (mimeType == null) {
      _setLoading(false);  // Hide loading spinner in case of an error
      throw Exception('Cannot determine the MIME type of the image.');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/upload'),
    );

    try {
      request.files.add(
        http.MultipartFile(
          'file',
          image.readAsBytes().asStream(),
          image.lengthSync(),
          filename: path.basename(image.path),
          contentType: MediaType.parse(mimeType),
        ),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final decodedResponse = json.decode(responseData);

        // Validate response data
        if (decodedResponse['url'] == null) {
          _setLoading(false);  // Hide loading spinner
          throw Exception('Failed to parse uploaded image URL from response.');
        }

        return decodedResponse['url'];
      } else {
        _setLoading(false);  // Hide loading spinner
        throw Exception('Failed to upload image: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error uploading image: $e');
      _setLoading(false);  // Hide loading spinner
      throw Exception('An error occurred while uploading image: $e');
    } finally {
      _setLoading(false);  // Hide loading spinner
    }
  }

  // Helper method to set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
