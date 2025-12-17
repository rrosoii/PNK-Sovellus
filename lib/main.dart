// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

import 'package:pnksovellus/pages/etusivu.dart';
import 'pages/home.dart';
import 'pages/omaterveys.dart';
import 'pages/chat.dart';
import 'pages/profile.dart';
import 'pages/log_in.dart'; // <-- login page
import 'pages/luo_tili.dart'; // <-- signup page
import 'routes/route_observer.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('fi_FI', null);

  runApp(const MyApp());

  // Initialize notifications after the UI is up so the splash screen
  // is not blocked if permissions hang.
  _setupNotifications();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('fi', 'FI'),
      navigatorObservers: [appRouteObserver],
      supportedLocales: const [Locale('fi', 'FI')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // 👇 THIS decides which screen loads first
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // If Firebase is still loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // 👇 User is logged in → go to Etusivu
          if (snapshot.hasData) {
            return const Etusivu();
          }

          // 👇 User is NOT logged in → go to Homepage
          return const Homepage();
        },
      ),

      routes: {
        '/etusivu': (context) => const Etusivu(),
        '/omaterveys': (context) => const TrackerPage(),
        '/chat': (context) => const ChatPage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}

Future<void> _setupNotifications() async {
  try {
    final notificationService = NotificationService();
    await notificationService.init();
    await notificationService.scheduleHydrationReminder();
    await notificationService.scheduleDailyExerciseReminder();

    // Listen for new events and notify if enabled
    final prefs = await SharedPreferences.getInstance();
    bool notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    if (notificationsEnabled) {
      DateTime lastCheck = DateTime.now();
      FirebaseFirestore.instance
          .collection('Tapahtumat')
          .orderBy('date', descending: true)
          .limit(1)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final doc = snapshot.docs.first;
          final data = doc.data() as Map<String, dynamic>;
          final timestamp = data['date'];
          DateTime eventDate = DateTime.now();
          if (timestamp is Timestamp) {
            eventDate = timestamp.toDate();
          } else if (timestamp is int) {
            eventDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
          } else if (timestamp is String) {
            eventDate = DateTime.tryParse(timestamp) ?? eventDate;
          }
          // Only notify for new events
          if (eventDate.isAfter(lastCheck)) {
            lastCheck = eventDate;
            notificationService.showNewEventNotification(
              data['title'] ?? 'Tapahtuma',
              body: data['description'],
            );
          }
        }
      });
    }
  } catch (e, st) {
    debugPrint('Notification setup failed: $e');
    debugPrintStack(stackTrace: st);
  }
}
