// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIModerationService {
  // Retrieve the OpenAI API key from .env
  static final String? apiKey = dotenv.env['OPENAI_API_KEY'];
  static const String apiUrl = 'https://api.openai.com/v1/moderations';

  // Function to check content for moderation
  Future<bool> checkContent(String content) async {
    if (apiKey == null || apiKey!.isEmpty) {
      _logError('API key is missing or empty. Ensure the .env file is correctly configured.');
      throw Exception('API key is missing or not configured.');
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode({'input': content}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Validate the response structure
        if (data['results'] == null || data['results'].isEmpty) {
          _logError('Unexpected API response structure: ${response.body}');
          throw Exception('Invalid API response: "results" field is missing or empty.');
        }

        // Check if the content is flagged
        final moderationResult = data['results'][0];
        return moderationResult['flagged'] ?? false;
      } else {
        _logHttpError(response);
        throw Exception('Failed to check content. HTTP status: ${response.statusCode}');
      }
    } catch (e) {
      // Log unexpected errors
      _logError('An unexpected error occurred: $e');
      rethrow; // Rethrow the error for the caller to handle
    }
  }

  // Helper to log HTTP errors
  void _logHttpError(http.Response response) {
    print('HTTP Error: Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
  }

  // Helper to log general errors
  void _logError(String message) {
    print('Error: $message');
  }
}
