// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:wod_book/auth/auth_provider.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../model/post_model.dart';
import '../services/api_service.dart';

class PostProvider with ChangeNotifier {
  List<Post> _posts = [];
  final ApiService _apiService;
  bool _isInitialized = false;
  AuthProvider? _authProvider;

  PostProvider(this._apiService) {
    _initializeProvider();
  }

  List<Post> get posts => _posts;

  // Initialize the provider, perform checks before using ApiService
  void _initializeProvider() {
    if (_apiService.token == null || _apiService.token!.isEmpty) {
      print('Error: API token is not initialized.');
      return;
    }
    _isInitialized = true;
  }

  // Helper function to check initialization
  bool _checkInitialization(String methodName) {
    if (!_isInitialized) {
      print(
          'Error: PostProvider is not initialized. $methodName cannot proceed.');
      return false;
    }
    return true;
  }

  // Update the API token (defensive programming)
  void updateToken(String newToken) {
    if (newToken.isEmpty) {
      print('Error: Token is empty. Cannot update.');
      return;
    }
    _apiService.updateToken(newToken);
    _isInitialized = true;
  }

  Future<void> fetchPosts() async {
    if (!_checkInitialization('fetchPosts')) return;

    try {
      print('Fetching posts...');
      _posts = await _apiService.getPosts();
      print('Posts fetched: $_posts');
      notifyListeners();
    } catch (e) {
      print('Error fetching posts: $e');
      throw Exception('Failed to load posts: $e');
    }
  }

  Future<void> fetchPostsByUser(int userId) async {
    if (!_checkInitialization('fetchPostsByUser')) return;

    try {
      print('Fetching posts by user...');
      _posts = await _apiService.getPosts();
      _posts = _posts
          .where((post) => post.userId == userId)
          .toList(); // Filter posts by userId
      print('Posts by user fetched: $_posts');
      notifyListeners();
    } catch (e) {
      print('Error fetching posts by user: $e');
      throw Exception('Failed to load posts by user: $e');
    }
  }

  Future<void> addPost(Post post) async {
    if (!_checkInitialization('addPost')) return;

    try {
      final newPost = await _apiService.createPost(post);
      _posts.add(newPost);
      notifyListeners();
    } catch (e) {
      print('Error creating post: $e');
      throw Exception('Failed to create post: $e');
    }
  }

  Future<void> addComment(int postId, Comment comment) async {
    if (!_checkInitialization('addComment')) return;

    try {
      final newComment = await _apiService.createComment(postId, comment);
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        _posts[postIndex].comments.add(newComment);
        notifyListeners();
      }
    } catch (e) {
      print('Error adding comment: $e');
      throw Exception('Failed to add comment: $e');
    }
  }

  Future<void> deleteComment(int postId, int commentId) async {
    if (!_checkInitialization('deleteComment')) return;

    try {
      await _apiService.deleteComment(postId, commentId);
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        _posts[postIndex]
            .comments
            .removeWhere((comment) => comment.id == commentId);
        notifyListeners();
      }
    } catch (e) {
      print('Error deleting comment: $e');
      throw Exception('Failed to delete comment: $e');
    }
  }

  Future<void> addLike(int postId) async {
    if (!_checkInitialization('addLike')) return;

    try {
      await _apiService.addLike(postId);
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        _posts[postIndex].likesCount += 1; // Increment the like count
        notifyListeners();
      }
    } catch (e) {
      print('Error adding like: $e');
      throw Exception('Failed to add like: $e');
    }
  }

  Post? getPostById(int postId) {
    if (!_checkInitialization('getPostById')) return null;
    return _posts.firstWhereOrNull((post) => post.id == postId);
  }

  Future<void> fetchComments(int postId) async {
    if (!_checkInitialization('fetchComments')) return;

    try {
      final comments = await _apiService.getComments(postId);
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        _posts[postIndex].comments = comments;
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching comments: $e');
      throw Exception('Failed to load comments: $e');
    }
  }

  Future<void> reportPost(int postId, String reason) async {
    final token = _authProvider?.token;
    if (token == null) {
      throw Exception('User is not authenticated');
    }

    // Load the base URL from .env file
    final baseUrl = dotenv.env['BASE_URL']; // Add dotenv package to your pubspec.yaml if not done already
    if (baseUrl == null) {
      throw Exception('Base URL is not configured in the environment');
    }

    final url = Uri.parse('$baseUrl/report/$postId');
    
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'reason': reason, // Add the reason here in the request body
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Handle success
      print('Post reported successfully');
    } else {
      throw Exception('Failed to report post');
    }
  }
}