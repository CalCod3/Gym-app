// model/schedule_model.dart
class Schedule {
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;

  Schedule({
    required int id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
    };
  }
}
