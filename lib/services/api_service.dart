// services/api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/post_model.dart';

class ApiService {
  static const String baseUrl = 'https://127.0.0.1:8001';

  Future<List<Post>> getPosts() async {
    final response = await http.get(Uri.parse('$baseUrl/posts/'));

    if (response.statusCode == 200) {
      Iterable l = json.decode(response.body);
      return List<Post>.from(l.map((model) => Post.fromJson(model)));
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<Post> createPost(Post post) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'title': post.title,
        'content': post.content,
      }),
    );

    if (response.statusCode == 201) {
      return Post.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create post');
    }
  }

  Future<List<Comment>> getComments(int postId) async {
    final response = await http.get(Uri.parse('$baseUrl/posts/$postId/comments/'));

    if (response.statusCode == 200) {
      Iterable l = json.decode(response.body);
      return List<Comment>.from(l.map((model) => Comment.fromJson(model)));
    } else {
      throw Exception('Failed to load comments');
    }
  }

  Future<Comment> createComment(int postId, Comment comment) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts/$postId/comments/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'content': comment.content,
      }),
    );

    if (response.statusCode == 201) {
      return Comment.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create comment');
    }
  }

  Future<void> deleteComment(int postId, int commentId) async {
    final response = await http.delete(Uri.parse('$baseUrl/posts/$postId/comments/$commentId'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete comment');
    }
  }
}
