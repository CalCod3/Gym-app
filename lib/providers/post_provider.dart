// providers/post_provider.dart
// ignore_for_file: avoid_print

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../model/post_model.dart';
import '../services/api_service.dart';

class PostProvider with ChangeNotifier {
  List<Post> _posts = [];
  final ApiService _apiService;

  PostProvider(this._apiService);

  List<Post> get posts => _posts;

  Future<void> fetchPosts() async {
    try {
      print('Fetching posts...');
      _posts = await _apiService.getPosts();
      print('Posts fetched: $_posts');
      notifyListeners();
    } catch (e) {
      print('Error fetching posts: $e');
      throw Exception('Failed to load posts');
    }
  }

  Future<void> addPost(Post post) async {
    try {
      final newPost = await _apiService.createPost(post);
      _posts.add(newPost);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to create post');
    }
  }

  Future<void> addComment(int postId, Comment comment) async {
    try {
      final newComment = await _apiService.createComment(postId, comment);
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        _posts[postIndex].comments.add(newComment);
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to add comment');
    }
  }

  Future<void> deleteComment(int postId, int commentId) async {
    try {
      await _apiService.deleteComment(postId, commentId);
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        _posts[postIndex].comments.removeWhere((comment) => comment.id == commentId);
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to delete comment');
    }
  }

  Future<void> addLike(int postId) async {
    try {
      await _apiService.addLike(postId); // Ensure this method is implemented in ApiService
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        _posts[postIndex].likesCount += 1; // Increment the like count
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to add like');
    }
  }

  Post? getPostById(int postId) {
    return _posts.firstWhereOrNull((post) => post.id == postId);
  }

  Future<void> fetchComments(int postId) async {
    try {
      final comments = await _apiService.getComments(postId);
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        _posts[postIndex].comments = comments;
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to load comments');
    }
  }
}
