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

  final String _baseUrl = dotenv.env['API_BASE_URL']!;

  Future<void> fetchActivities() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('$_baseUrl/activities'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _activities = data.map((json) => ActivityModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load activities');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createActivity(ActivityModel activity) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/admin/activities/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(activity.toJson()),
      );

      if (response.statusCode == 201) {
        fetchActivities();
      } else {
        throw Exception('Failed to create activity');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<String?> uploadImage(File image) async {
    final mimeType = lookupMimeType(image.path);
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/upload'),
    );

    request.files.add(
      http.MultipartFile(
        'file',
        image.readAsBytes().asStream(),
        image.lengthSync(),
        filename: path.basename(image.path),
        contentType: mimeType != null ? MediaType.parse(mimeType) : null,
      ),
    );

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final decodedResponse = json.decode(responseData);
        return decodedResponse['url']; // Assuming the backend returns the URL in 'url'
      } else {
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }
}
