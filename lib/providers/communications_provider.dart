// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CommunicationsProvider with ChangeNotifier {
  List<Article> _articles = [];

  List<Article> get articles => _articles;

  final String _baseUrl;

  CommunicationsProvider() : _baseUrl = dotenv.env['API_BASE_URL']! {
    if (_baseUrl.isEmpty) {
      throw Exception('API base URL is not set. Please check your .env file.');
    }
  }

  // Fetch articles from the backend
  Future<void> fetchArticles() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/news'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        // Validate response data
        if (data.isEmpty) {
          throw Exception('No articles found');
        }

        _articles = data.map((article) => Article.fromJson(article)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load articles: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching articles: $e');
      throw Exception('An error occurred while fetching articles: $e');
    }
  }

  // Add a new article
  Future<void> addArticle(Article article) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/admin/news/new'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(article.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchArticles(); // Refresh articles after successfully adding one
        await sendNotification(article); // Send notification with article details
      } else {
        throw Exception('Failed to add article: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error adding article: $e');
      throw Exception('An error occurred while adding the article: $e');
    }
  }
  
  // Send notification to all users about the new article
  Future<void> sendNotification(Article article) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/notifications'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'title': 'New Article: ${article.title}',
          'message': 'Check out the latest article: ${article.title}',
          'preview': article.body.substring(0, 50), // Short preview of the article
        }),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        throw Exception('Failed to send notification: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error sending notification: $e');
      throw Exception('An error occurred while sending notification: $e');
    }
  }
}

class Article {
  final String title;
  final String body;
  final String date;

  Article({
    required this.title,
    required this.body,
    required this.date,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'],
      body: json['body'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'date': date,
    };
  }
}
