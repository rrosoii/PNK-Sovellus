// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pnksovellus/pages/etusivu.dart';
import 'pages/home.dart';
import 'pages/omaterveys.dart';
import 'pages/chat.dart';
import 'pages/profile.dart'; // <-- your REAL profile page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const Homepage(),
        '/etusivu': (context) => const Etusivu(),
        '/omaterveys': (context) => const TrackerPage(),
        '/chat': (context) => const ChatPage(),
        '/profile': (context) => const ProfilePage(), // <-- this now works
      },
    );
  }
}
