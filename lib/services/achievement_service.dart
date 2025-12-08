import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AchievementService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  /// Loads achievements as a map of {id: title}
  Future<Map<String, String>> loadAchievements() async {
    if (_uid == null) return {};
    final snap = await _firestore.collection('users').doc(_uid).get();
    final data = snap.data();
    if (data == null) return {};
    final ach = data['achievements'];
    if (ach is Map) {
      return ach.map((key, value) => MapEntry(key.toString(), value.toString()));
    }
    return {};
  }

  /// Adds an achievement if it doesn't exist yet.
  Future<void> award(String id, String title) async {
    if (_uid == null) return;
    await _firestore.collection('users').doc(_uid).set({
      'achievements': {id: title}
    }, SetOptions(merge: true));
  }
}
