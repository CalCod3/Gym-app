// model/performance_model.dart
class Performance {
  final int id;
  final String category;
  final int weight;
  final int userId;

  Performance({
    required this.id,
    required this.category,
    required this.weight,
    required this.userId,
  });

  factory Performance.fromJson(Map<String, dynamic> json) {
    return Performance(
      id: json['id'],
      category: json['category'],
      weight: json['weight'],
      userId: json['user_id'],
    );
  }
}
