import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';  // Import dotenv package

class OpenAIModerationService {
  // Retrieve the OpenAI API key from .env
  static String? apiKey = dotenv.env['OPENAI_API_KEY']; // Fetch API key from .env file
  static const String apiUrl = 'https://api.openai.com/v1/moderations';

  // Function to check content for moderation
  Future<bool> checkContent(String content) async {
    if (apiKey == null) {
      throw Exception('API key is missing in the .env file.');
    }

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey', // Use the API key from the .env file
      },
      body: json.encode({
        'input': content, // Text to be analyzed
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // The moderation result will be in the `results` field
      final moderationResult = data['results'][0];

      // Check if the content is flagged as harmful
      return moderationResult['flagged'] ?? false;
    } else {
      throw Exception('Failed to check content');
    }
  }
}
