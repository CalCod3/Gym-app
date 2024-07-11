// models/post.dart
class Post {
  final int id;
  final String title;
  final String content;
  final int userId;
  final List<Comment> comments;

  Post(
      {required this.id,
      required this.title,
      required this.content,
      required this.userId,
      required this.comments});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      userId: json['user_id'],
      comments:
          (json['comments'] as List).map((i) => Comment.fromJson(i)).toList(),
    );
  }
}

// models/comment.dart
class Comment {
  final int id;
  final String content;
  final int postId;
  final int userId;

  Comment(
      {required this.id,
      required this.content,
      required this.postId,
      required this.userId});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      content: json['content'],
      postId: json['post_id'],
      userId: json['user_id'],
    );
  }
}
