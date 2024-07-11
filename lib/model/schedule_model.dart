// model/schedule_model.dart
class Schedule {
  final int id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final int userId;

  Schedule({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.userId,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      userId: json['user_id'],
    );
  }
}
