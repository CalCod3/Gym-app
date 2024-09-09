// ignore_for_file: avoid_print

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/post_model.dart';

class ApiService {
  final String baseUrl;
  String? token;

  ApiService(this.token) : baseUrl = dotenv.env['API_BASE_URL']! {
    if (baseUrl.isEmpty) {
      throw Exception('API base URL is not set. Check your .env file.');
    }
    if (token == null || token!.isEmpty) {
      print('Warning: API token is not initialized.');
    }
  }

  void updateToken(String newToken) {
    if (newToken.isEmpty) {
      print('Error: Cannot update token with an empty value.');
    } else {
      token = newToken;
      print('Token updated successfully.');
    }
  }

  Future<List<Post>> getPosts() async {
    _checkToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts/'),
        headers: {'Authorization': 'Bearer $token!'},
      );

      print('Raw response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data == null || data is! List) {
          throw Exception('Invalid data format');
        }

        return List<Post>.from(data.map((model) => Post.fromJson(model)));
      } else {
        throw Exception('Failed to load posts: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching posts: $e');
      rethrow;
    }
  }

  Future<Post> createPost(Post post) async {
    _checkToken();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token!'
        },
        body: json.encode({
          'title': post.title,
          'content': post.content,
        }),
      );

      if (response.statusCode == 201) {
        return Post.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create post: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error creating post: $e');
      rethrow;
    }
  }

  Future<List<Comment>> getComments(int postId) async {
    _checkToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts/$postId/comments/'),
        headers: {'Authorization': 'Bearer $token!'},
      );

      if (response.statusCode == 200) {
        Iterable l = json.decode(response.body);
        return List<Comment>.from(l.map((model) => Comment.fromJson(model)));
      } else {
        throw Exception('Failed to load comments: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching comments: $e');
      rethrow;
    }
  }

  Future<Comment> createComment(int postId, Comment comment) async {
    _checkToken();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts/$postId/comments/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token!'
        },
        body: json.encode({
          'content': comment.content,
        }),
      );

      if (response.statusCode == 201) {
        return Comment.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create comment: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error creating comment: $e');
      rethrow;
    }
  }

  Future<void> deleteComment(int postId, int commentId) async {
    _checkToken();
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/posts/$postId/comments/$commentId'),
        headers: {'Authorization': 'Bearer $token!'},
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete comment: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error deleting comment: $e');
      rethrow;
    }
  }

  Future<void> addLike(int postId) async {
    _checkToken();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts/$postId/like/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token!'
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to like post: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error adding like: $e');
      rethrow;
    }
  }

  // Defensive programming method to check if the token is available
  void _checkToken() {
    if (token == null || token!.isEmpty) {
      throw Exception('API token is not initialized or empty.');
    }
  }
}
