class Article {
  final String title;
  final String content;
  final String date;

  Article({
    required this.title,
    required this.content,
    required this.date,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'],
      content: json['body'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': content,
      'date': date,
    };
  }
}
