class Article {
  final String id;
  final String title;
  final String author;
  final String date;
  final String category;
  final String content;
  final String imageUrl;

  Article({
    required this.id,
    required this.title,
    required this.author,
    required this.date,
    required this.category,
    required this.content,
    required this.imageUrl,
  });

  factory Article.fromFirestore(String id, Map<String, dynamic> data) {
    return Article(
      id: id,
      title: data["title"] ?? "",
      author: data["author"] ?? "",
      date: data["date"] ?? "",
      category: data["category"] ?? "",
      content: data["content"] ?? "",
      imageUrl: data["imageUrl"] ?? "",
    );
  }
}
