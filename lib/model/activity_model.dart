// model/activity_model.dart
class ActivityModel {
  String image;
  final String value;
  final String title;
  final String description;

  ActivityModel({
    required this.image,
    required this.value,
    required this.title,
    required this.description,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      image: json['image'],
      value: json['value'],
      title: json['title'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image': image,
      'value': value,
      'title': title,
      'description': description,
    };
  }
}
