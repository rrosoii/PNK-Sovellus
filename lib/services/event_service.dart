import 'package:cloud_firestore/cloud_firestore.dart';

class EventItem {
  final String id;
  final String title;
  final DateTime date;
  final String? location;
  final String? description;

  EventItem({
    required this.id,
    required this.title,
    required this.date,
    this.location,
    this.description,
  });

  factory EventItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final timestamp = data['date'];
    DateTime date = DateTime.now();
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else if (timestamp is int) {
      date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    } else if (timestamp is String) {
      date = DateTime.tryParse(timestamp) ?? date;
    }

    return EventItem(
      id: doc.id,
      title: (data['title'] ?? 'Tapahtuma') as String,
      date: date,
      location: data['location'] as String?,
      description: data['description'] as String?,
    );
  }
}

class EventService {
  final _firestore = FirebaseFirestore.instance;

  Stream<List<EventItem>> upcomingEvents({int limit = 10}) {
    final now = DateTime.now();
    return _firestore
        .collection('Tapahtumat')
        .where('date', isGreaterThanOrEqualTo: now)
        .orderBy('date')
        .limit(limit)
        .snapshots()
        .map(
      (snap) {
        return snap.docs.map(EventItem.fromDoc).toList();
      },
    );
  }
}
