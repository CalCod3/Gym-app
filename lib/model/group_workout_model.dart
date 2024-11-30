// models/group_workout_model.dart
class GroupWorkout {
  final int id;
  final String title;
  final String description;
  final DateTime date;
  final List<String> videoLinks;
  final String type;

  GroupWorkout({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.videoLinks,
    required this.type,
  });

  factory GroupWorkout.fromJson(Map<String, dynamic> json) {
    return GroupWorkout(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      videoLinks: List<String>.from(json['video_links']), 
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'video_links': videoLinks,
      'type': type,
    };
  }
}
