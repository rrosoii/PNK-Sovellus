import 'package:cloud_firestore/cloud_firestore.dart';
import 'article_model.dart';

class ArticleService {
  final CollectionReference _ref = FirebaseFirestore.instance.collection(
    "Artikkelit",
  );

  Future<List<Article>> getArticles() async {
    final snapshot = await _ref.get();
    return snapshot.docs
        .map(
          (doc) =>
              Article.fromFirestore(doc.id, doc.data() as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<Article>> getArticlesByCategory(String category) async {
    final snapshot = await _ref.where("category", isEqualTo: category).get();
    return snapshot.docs
        .map(
          (doc) =>
              Article.fromFirestore(doc.id, doc.data() as Map<String, dynamic>),
        )
        .toList();
  }
}
