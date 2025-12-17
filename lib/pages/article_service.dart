import 'package:cloud_firestore/cloud_firestore.dart';
import 'article_model.dart';

class ArticleService {
  final CollectionReference _ref = FirebaseFirestore.instance.collection(
    "Artikkelit",
  );

  Future<List<Article>> getArticles() async {
    try {
      final snapshot = await _ref.get();
      return snapshot.docs
          .map(
            (doc) => Article.fromFirestore(
              doc.id,
              doc.data() as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Article>> getArticlesByCategory(String category) async {
    try {
      // Normalize UI category to possible DB values.
      // Preferred DB key is lowercase with underscores, e.g. "voi_paremmin".
      final ui = category;
      final dbKey = ui.toLowerCase().replaceAll(' ', '_');
      final alt1 = ui;
      final alt2 = ui.isNotEmpty
          ? ui[0].toUpperCase() + ui.substring(1)
          : ui; // capitalized

      // Build candidate list for whereIn query (Firestore supports up to 10 items).
      final candidates = <String>{dbKey, alt1, alt2}.toList();

      QuerySnapshot snapshot;
      if (candidates.length == 1) {
        snapshot = await _ref.where("category", isEqualTo: candidates.first).get();
      } else {
        snapshot = await _ref.where("category", whereIn: candidates).get();
      }
      return snapshot.docs
          .map(
            (doc) => Article.fromFirestore(
              doc.id,
              doc.data() as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
