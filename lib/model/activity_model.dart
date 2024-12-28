// model/activity_model.dart
class ActivityModel {
  String? image;
  final String? value;
  final String? title;
  final String? description;
  final String? type;

  ActivityModel({
    this.image,
    this.value,
    this.title,
    this.description,
    this.type
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      image: json['image'],
      value: json['value'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image': image,
      'value': value,
      'title': title,
      'description': description,
      'type': type,
    };
  }
}
