import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    return NotificationItem(
      id: map['id'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}

class NotificationHistoryService {
  static const String _storageKey = 'notification_history';
  static const int _maxNotifications = 20;

  /// Add a new notification to history
  Future<void> addNotification(String title, String body) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final id = '${now.millisecondsSinceEpoch}_${title.hashCode}';

    final notification = NotificationItem(
      id: id,
      title: title,
      body: body,
      timestamp: now,
    );

    final history = await getNotifications();
    history.insert(0, notification);

    // Keep only the latest 20 notifications
    if (history.length > _maxNotifications) {
      history.removeRange(_maxNotifications, history.length);
    }

    final jsonList = history.map((n) => jsonEncode(n.toMap())).toList();
    await prefs.setStringList(_storageKey, jsonList);
  }

  /// Get all notifications from history
  Future<List<NotificationItem>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_storageKey) ?? [];

    return jsonList.map((json) {
      return NotificationItem.fromMap(jsonDecode(json));
    }).toList();
  }

  /// Clear all notifications
  Future<void> clearNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  /// Get the latest N notifications
  Future<List<NotificationItem>> getLatestNotifications(int count) async {
    final all = await getNotifications();
    return all.take(count).toList();
  }
}
