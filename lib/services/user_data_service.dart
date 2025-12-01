import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileData {
  final String username;
  final String profileType;
  final String? avatarPath;

  const UserProfileData({
    required this.username,
    required this.profileType,
    this.avatarPath,
  });
}

class UserDataService {
  final _firestore = FirebaseFirestore.instance;

  bool get _isLoggedIn => FirebaseAuth.instance.currentUser != null;
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Future<SharedPreferences> get _prefs async =>
      SharedPreferences.getInstance();

  Future<Map<String, dynamic>?> _fetchUserDoc() async {
    if (!_isLoggedIn) return null;
    final snap =
        await _firestore.collection('users').doc(_uid).get(const GetOptions());
    return snap.data();
  }

  Future<void> _merge(Map<String, dynamic> data) async {
    if (!_isLoggedIn) return;
    await _firestore
        .collection('users')
        .doc(_uid)
        .set(data, SetOptions(merge: true));
  }

  Future<UserProfileData> loadProfileData() async {
    final prefs = await _prefs;
    String username = prefs.getString('username') ?? 'Lissu';
    String profileType = prefs.getString('userProfile') ?? 'Koala';
    String? avatarPath = prefs.getString('avatar_path');

    if (_isLoggedIn) {
      final doc = await _fetchUserDoc();
      final profile = doc?['profile'];
      if (profile is Map<String, dynamic>) {
        username = (profile['username'] ?? username) as String;
        profileType = (profile['profileType'] ?? profileType) as String;
        avatarPath = profile['avatarPath'] as String? ?? avatarPath;
      }

      await prefs.setString('username', username);
      await prefs.setString('userProfile', profileType);
      if (avatarPath != null) {
        await prefs.setString('avatar_path', avatarPath);
      }
    }

    return UserProfileData(
      username: username,
      profileType: profileType,
      avatarPath: avatarPath,
    );
  }

  Future<void> saveProfileName(String name) async {
    final prefs = await _prefs;
    await prefs.setString('username', name);
    await _merge({
      'profile': {'username': name}
    });
  }

  Future<void> saveProfileType(String type) async {
    final prefs = await _prefs;
    await prefs.setString('userProfile', type);
    await _merge({
      'profile': {'profileType': type}
    });
  }

  Future<void> saveAvatarPath(String path) async {
    final prefs = await _prefs;
    await prefs.setString('avatar_path', path);
    await _merge({
      'profile': {'avatarPath': path}
    });
  }

  Future<List<String>> loadCustomActivities() async {
    final prefs = await _prefs;
    List<String> activities = prefs.getStringList('custom_activities') ?? [];

    if (_isLoggedIn) {
      final doc = await _fetchUserDoc();
      final remote = doc?['customActivities'];
      if (remote is List) {
        activities = remote.map((e) => e.toString()).toList();
        await prefs.setStringList('custom_activities', activities);
      }
    }

    return activities;
  }

  Future<void> saveCustomActivities(List<String> activities) async {
    final prefs = await _prefs;
    await prefs.setStringList('custom_activities', activities);
    await _merge({'customActivities': activities});
  }

  Future<String?> loadMoodData(String monthKey) async {
    final prefs = await _prefs;
    String? value = prefs.getString(monthKey);

    if (_isLoggedIn) {
      final doc = await _fetchUserDoc();
      final moods = doc?['moods'];
      if (moods is Map<String, dynamic>) {
        value = moods[monthKey] as String? ?? value;
      }
      if (value != null) {
        await prefs.setString(monthKey, value);
      }
    }

    return value;
  }

  Future<void> saveMoodData(String monthKey, String encoded) async {
    final prefs = await _prefs;
    await prefs.setString(monthKey, encoded);
    await _merge({
      'moods': {monthKey: encoded}
    });
  }

  Future<String?> loadExerciseData(String monthKey) async {
    final prefs = await _prefs;
    String? value = prefs.getString(monthKey);

    if (_isLoggedIn) {
      final doc = await _fetchUserDoc();
      final exercises = doc?['exercises'];
      if (exercises is Map<String, dynamic>) {
        value = exercises[monthKey] as String? ?? value;
      }
      if (value != null) {
        await prefs.setString(monthKey, value);
      }
    }

    return value;
  }

  Future<void> saveExerciseData(String monthKey, String encoded) async {
    final prefs = await _prefs;
    await prefs.setString(monthKey, encoded);
    await _merge({
      'exercises': {monthKey: encoded}
    });
  }

  /// Pulls all user doc data into local prefs so a fresh device hydrates.
  Future<void> syncFromCloudToLocal() async {
    if (!_isLoggedIn) return;
    final doc = await _fetchUserDoc();
    if (doc == null) return;
    final prefs = await _prefs;

    // Profile
    final profile = doc['profile'];
    if (profile is Map<String, dynamic>) {
      if (profile['username'] is String) {
        await prefs.setString('username', profile['username'] as String);
      }
      if (profile['profileType'] is String) {
        await prefs.setString('userProfile', profile['profileType'] as String);
      }
      if (profile['avatarPath'] is String) {
        await prefs.setString('avatar_path', profile['avatarPath'] as String);
      }
    }

    // Activities / moods / exercises
    final custom = doc['customActivities'];
    if (custom is List) {
      await prefs.setStringList(
        'custom_activities',
        custom.map((e) => e.toString()).toList(),
      );
    }

    final moods = doc['moods'];
    if (moods is Map<String, dynamic>) {
      for (final entry in moods.entries) {
        if (entry.value is String) {
          await prefs.setString(entry.key, entry.value as String);
        }
      }
    }

    final exercises = doc['exercises'];
    if (exercises is Map<String, dynamic>) {
      for (final entry in exercises.entries) {
        if (entry.value is String) {
          await prefs.setString(entry.key, entry.value as String);
        }
      }
    }
  }

  /// Increment exercise-based challenges for a specific date (when the user logs an exercise).
  Future<void> recordExerciseForDate(DateTime date, {int count = 1}) async {
    if (!_isLoggedIn) return;

    final snap =
        await _firestore.collection('users').doc(_uid).get(const GetOptions());
    final data = snap.data();
    if (data == null) return;

    final active = Map<String, dynamic>.from(
      data['activeChallenges'] as Map<String, dynamic>? ?? {},
    );

    if (active.isEmpty) return;

    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    bool updated = false;

    active.forEach((id, value) {
      if (value is! Map) return;
      if (value['isActive'] != true) return;
      final type = value['type'] as String? ?? '';
      if (type != 'exerciseWeekly' && type != 'exercise') return;

      final start = DateTime.tryParse(value['startDate'] ?? '');
      final durationDays = (value['durationDays'] ?? 7) as int;
      if (start == null) return;
      final end = start.add(Duration(days: durationDays));

      if (date.isBefore(start) || date.isAfter(end)) return;

      final daily = Map<String, dynamic>.from(
        value['dailyProgress'] as Map<String, dynamic>? ?? {},
      );
      final current = (daily[dateKey] ?? 0) is num
          ? (daily[dateKey] as num).toInt()
          : int.tryParse(daily[dateKey].toString()) ?? 0;
      daily[dateKey] = current + count;

      value['dailyProgress'] = daily;
      updated = true;
    });

    if (updated) {
      await _firestore
          .collection('users')
          .doc(_uid)
          .set({'activeChallenges': active}, SetOptions(merge: true));
    }
  }

  /// Update step-based challenges (per-day or accumulated).
  Future<void> recordStepsForDate(DateTime date, int steps) async {
    if (!_isLoggedIn) return;

    final snap =
        await _firestore.collection('users').doc(_uid).get(const GetOptions());
    final data = snap.data();
    if (data == null) return;

    final active = Map<String, dynamic>.from(
      data['activeChallenges'] as Map<String, dynamic>? ?? {},
    );

    if (active.isEmpty) return;

    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    bool updated = false;

    active.forEach((id, value) {
      if (value is! Map) return;
      if (value['isActive'] != true) return;
      final type = value['type'] as String? ?? '';
      if (type != 'steps' && type != 'stepsAccumulated') return;

      final start = DateTime.tryParse(value['startDate'] ?? '');
      final durationDays = (value['durationDays'] ?? 7) as int;
      if (start == null) return;
      final end = start.add(Duration(days: durationDays));

      if (date.isBefore(start) || date.isAfter(end)) return;

      final daily = Map<String, dynamic>.from(
        value['dailyProgress'] as Map<String, dynamic>? ?? {},
      );
      daily[dateKey] = steps;

      value['dailyProgress'] = daily;
      updated = true;
    });

    if (updated) {
      await _firestore
          .collection('users')
          .doc(_uid)
          .set({'activeChallenges': active}, SetOptions(merge: true));
    }
  }
}
