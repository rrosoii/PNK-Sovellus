import 'package:cloud_firestore/cloud_firestore.dart';

class AjankohtaistaItem {
  final String id;
  final String title;
  final DateTime date;
  final String? imageUrl;
  final String? body;

  AjankohtaistaItem({
    required this.id,
    required this.title,
    required this.date,
    this.imageUrl,
    this.body,
  });

  factory AjankohtaistaItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final rawDate = data['date'];
    DateTime date = DateTime.now();
    if (rawDate is Timestamp) {
      date = rawDate.toDate();
    } else if (rawDate is int) {
      date = DateTime.fromMillisecondsSinceEpoch(rawDate);
    } else if (rawDate is String) {
      date = DateTime.tryParse(rawDate) ?? date;
    }

    return AjankohtaistaItem(
      id: doc.id,
      title: (data['title'] ?? 'Ajankohtaista') as String,
      date: date,
      imageUrl: data['imageUrl'] as String?,
      body: data['body'] as String? ?? data['text'] as String?,
    );
  }
}

class AjankohtaistaService {
  final _firestore = FirebaseFirestore.instance;

  Stream<List<AjankohtaistaItem>> latest({int limit = 10}) {
    return _firestore
        .collection('Ajankohtaista')
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(AjankohtaistaItem.fromDoc).toList());
  }
}
