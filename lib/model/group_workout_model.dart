// models/group_workout_model.dart
class GroupWorkout {
  final int id;
  final String name;
  final String description;
  final DateTime date;
  final List<String> videoLinks;
  final String type;

  GroupWorkout({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.videoLinks,
    required this.type,
  });

  factory GroupWorkout.fromJson(Map<String, dynamic> json) {
    return GroupWorkout(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      videoLinks: List<String>.from(json['video_links']), 
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'date': date.toIso8601String(),
      'video_links': videoLinks,
      'type': type,
    };
  }
}
