// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class BoxProvider with ChangeNotifier {
  Map<String, dynamic> _boxDetails = {};
  List<dynamic> _members = [];
  List<dynamic> _payments = [];
  List<dynamic> _paymentPlans = [];

  Map<String, dynamic> get boxDetails => _boxDetails;
  List<dynamic> get members => _members;
  List<dynamic> get payments => _payments;
  List<dynamic> get paymentPlans => _paymentPlans;

  final String _baseUrl;

  BoxProvider() : _baseUrl = dotenv.env['API_BASE_URL']! {
    if (_baseUrl.isEmpty) {
      throw Exception('API base URL is not set. Please check your .env file.');
    }
  }

  // Fetch box details including members, payments, and payment plans
  Future<void> fetchBoxDetails(String boxId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/boxes/$boxId'),
        headers: {
          'Authorization': 'Bearer YOUR_TOKEN', // Replace with actual token handling
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Validate response data
        if (data == null || data.isEmpty || !data.containsKey('members')) {
          throw Exception('Invalid data format received for box details.');
        }

        _boxDetails = data;
        _members = data['members'];
        _payments = data['payments'];
        _paymentPlans = data['payment_plans'];
        notifyListeners();
      } else {
        throw Exception('Failed to load box details: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching box details: $e');
      throw Exception('An error occurred while fetching box details: $e');
    }
  }

  // Update box details (without image)
  Future<void> updateBoxDetails(String boxId, Map<String, dynamic> newDetails) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/boxes/$boxId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_TOKEN', // Replace with actual token handling
        },
        body: json.encode(newDetails),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _boxDetails = json.decode(response.body);
        notifyListeners();
      } else {
        throw Exception('Failed to update box details: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error updating box details: $e');
      throw Exception('An error occurred while updating box details: $e');
    }
  }

  // Update box details with profile image upload
  Future<void> updateBoxDetailsWithImage(String boxId, Map<String, dynamic> newDetails, File imageFile) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/boxes/$boxId');
      final request = http.MultipartRequest('PUT', uri);

      // Add token handling
      request.headers['Authorization'] = 'Bearer YOUR_TOKEN'; // Replace with actual token handling

      // Add other box details as fields
      newDetails.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      // Attach the image file
      final mimeType = lookupMimeType(imageFile.path);
      if (mimeType == null) {
        throw Exception('Cannot determine the MIME type of the image.');
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_image',  // This should match your backend API field for the image
          imageFile.path,
          contentType: MediaType.parse(mimeType),
        ),
      );

      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = await response.stream.bytesToString();
        _boxDetails = json.decode(responseBody);
        notifyListeners();
      } else {
        throw Exception('Failed to update box details with image: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error updating box details with image: $e');
      throw Exception('An error occurred while updating box details with image: $e');
    }
  }
}
