import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Article {
  final String id;
  final String title;
  final String author;
  final String date;
  final String category;
  final String content;
  final String imageUrl;
  final String link;

  Article({
    required this.id,
    required this.title,
    required this.author,
    required this.date,
    required this.category,
    required this.content,
    required this.imageUrl,
    this.link = '',
  });

  factory Article.fromFirestore(String id, Map<String, dynamic> data) {
    String formatDate(dynamic value) {
      if (value is String) return value;
      // Handle Firestore Timestamp
      try {
        if (value is Timestamp) {
          return DateFormat("dd.MM.yyyy").format(value.toDate());
        }
      } catch (_) {}
      return "";
    }

    return Article(
      id: id,
      title: data["title"] ?? "",
      author: data["author"] ?? "",
      date: formatDate(data["date"]),
      category: data["category"] ?? "",
      content: data["content"] ?? "",
      imageUrl: data["imageUrl"] ?? "",
      link: data["link"] ?? "",
    );
  }
}
