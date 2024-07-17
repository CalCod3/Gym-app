// providers/post_provider.dart
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
      _posts = await _apiService.getPosts();
      notifyListeners();
    } catch (e) {
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
}
