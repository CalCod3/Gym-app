// models/post.dart
// ignore_for_file: avoid_print

class Post {
  final int id;
  final String title;
  final String content;
  final int userId;
  final String userProfileImageUrl; // Stores profile image URL
  final String userName; // Stores user first name
  late final List<Comment> comments;
  int likesCount;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.userId,
    required this.userProfileImageUrl,
    required this.userName,
    required this.comments,
    this.likesCount = 0,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    print('Post.fromJson: $json');

    return Post(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      userId: json['user']['id'] ?? 0, // Access user_id from nested user object
      userProfileImageUrl: json['user']['profile_image'] ?? '', // Fetch profile image from nested user object
      userName: json['user']['first_name'] ?? '', // Fetch user first name from nested user object
      comments: (json['comments'] as List<dynamic>?)
          ?.map((i) => Comment.fromJson(i as Map<String, dynamic>))
          .toList() ?? [],
      likesCount: json['likes_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'user_id': userId,
      'user_profile_image_url': userProfileImageUrl, // Include this field
      'user_name': userName, // Include this field
      'comments': comments.map((comment) => comment.toJson()).toList(),
      'likes_count': likesCount,
    };
  }
}

// models/comment.dart
class Comment {
  final int id;
  final String content;
  final int postId;
  final int userId;

  Comment({
    required this.id,
    required this.content,
    required this.postId,
    required this.userId,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    // Print the JSON for debugging
    print('Comment.fromJson: $json');
    
    return Comment(
      id: json['id'] ?? 0,
      content: json['content'] ?? '',
      postId: json['post_id'] ?? 0,
      userId: json['user_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'post_id': postId,
      'user_id': userId,
    };
  }
}
