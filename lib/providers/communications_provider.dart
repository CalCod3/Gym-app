// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CommunicationsProvider with ChangeNotifier {
  List<Article> _articles = [];

  List<Article> get articles => _articles;

  Future<void> fetchArticles() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8001/api/news'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        _articles = data.map((article) => Article.fromJson(article)).toList();
        notifyListeners();
      } else {
        // Handle non-200 responses
        print('Failed to load articles. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any exceptions
      print('Error fetching articles: $e');
    }
  }

  Future<void> addArticle(Article article) async {
  try {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8001/admin/news/new'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(article.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Fetch the updated list of articles
      await fetchArticles();
    } else {
      // Handle non-201 responses
      print('Failed to add article. Status code: ${response.statusCode}');
    }
  } catch (e) {
    // Handle any exceptions
    print('Error adding article: $e');
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
      body: json['body'], // Ensure this matches the response model
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body, // Ensure this matches the request model
      'date': date,
    };
  }
}
