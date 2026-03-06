// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:pnksovellus/pages/log_in.dart';
import 'package:pnksovellus/pages/luo_tili.dart';
import 'package:pnksovellus/pages/etusivu.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return const WelcomePage();
  }
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    _checkPopup();
  }

  Future<void> _checkPopup() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final hasShown = prefs.getBool('hasShownCodePopup') ?? false;

      if (!hasShown) {
        // fetch text from firebase
        final doc = await FirebaseFirestore.instance
            .collection('app_content')
            .doc('alku_tietosuoja')
            .get();

        final privacyText = doc.data()?['text'] ?? "Tietosuojateksti puuttuu.";

        if (mounted) {
          _showPrivacyPopup(privacyText);
        }
      }
    });
  }

  void _showPrivacyPopup(String text) async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: const Color.fromARGB(255, 227, 235, 253),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Tietosuojakäytäntö',
                  style: TextStyle(
                    color: Color.fromRGBO(13, 59, 128, 1),
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 260,
                  child: SingleChildScrollView(
                    child: Text(
                      text,
                      style: const TextStyle(
                          fontSize: 16, color: Color.fromRGBO(13, 59, 128, 1)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E5AAC),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () async {
                      await prefs.setBool('hasShownCodePopup', true);
                      if (mounted) Navigator.of(ctx).pop();
                    },
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 227, 235, 253),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -30,
              left: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(46, 90, 172, 0.18),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: -30,
              left: 45,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(46, 90, 172, 0.14),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 150),
                Center(
                  child: Image.asset(
                    'lib/images/pnk-sininen-fi.png',
                    height: 250,
                  ),
                ),
                const SizedBox(height: 18),
                const Center(
                  child: Text(
                    'Tervetuloa!',
                    style: TextStyle(
                      color: Color.fromRGBO(13, 59, 128, 1),
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                ),
                const SizedBox(height: 80),
                Center(
                  child: SizedBox(
                    width: screenWidth * 0.67,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E5AAC),
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Luotili()),
                        );
                      },
                      child: const Text(
                        'Luo tili',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: "Onko sinulla jo tili? ",
                      style: const TextStyle(color: Colors.black87),
                      children: [
                        TextSpan(
                          text: "Kirjaudu sisään",
                          style: TextStyle(
                            color: const Color(0xFF3066BE),
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Login(),
                                ),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Etusivu()),
                      );
                    },
                    child: Text(
                      'Selaa kirjautumatta >',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 110, 111, 118),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
