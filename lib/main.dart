// ignore_for_file: unused_import

import 'package:flutter/material.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('fi_FI', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('fi', 'FI'),

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

          // 👇 User is NOT logged in → go to LoginPage
          return const LoginPage();
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
