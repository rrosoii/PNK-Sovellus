// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  } catch (e, st) {
    debugPrint('Notification setup failed: $e');
    debugPrintStack(stackTrace: st);
  }
}
