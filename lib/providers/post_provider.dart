// providers/post_provider.dart
import 'package:flutter/material.dart';
import '../model/post_model.dart';
import '../services/api_service.dart';

class PostProvider with ChangeNotifier {
  List<Post> _posts = [];
  final ApiService _apiService = ApiService();

  List<Post> get posts => _posts;

  Future<void> fetchPosts() async {
    _posts = await _apiService.getPosts();
    notifyListeners();
  }

  Future<void> addPost(Post post) async {
    Post newPost = await _apiService.createPost(post);
    _posts.add(newPost);
    notifyListeners();
  }

  Future<void> addComment(int postId, Comment comment) async {
    Comment newComment = await _apiService.createComment(postId, comment);
    _posts.firstWhere((post) => post.id == postId).comments.add(newComment);
    notifyListeners();
  }
}
