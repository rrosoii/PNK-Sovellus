import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = "Lissu";
  String? profileType = "Koala"; // default
  File? avatarImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString("username") ?? "Lissu";
    profileType = prefs.getString("userProfile") ?? "Koala";

    String? avatarPath = prefs.getString("avatar_path");
    if (avatarPath != null && File(avatarPath).existsSync()) {
      avatarImage = File(avatarPath);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7F0FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // TOP BLUE GRADIENT WITH WAVE
              Stack(
                children: [
                  Container(
                    height: 190,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1F3C88), Color(0xFF0A2E68)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  // Wave curve (placeholder)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 55,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(60),
                          topRight: Radius.circular(60),
                        ),
                      ),
                    ),
                  ),

                  // BACK + TITLE
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Row(
                      children: const [
                        Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 22,
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.person, color: Colors.white, size: 26),
                        SizedBox(width: 8),
                        Text(
                          "Profiili",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // AVATAR + NAME
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        // Avatar circle
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 42,
                            backgroundColor: const Color(0xFFE7F0FF),
                            backgroundImage: avatarImage != null
                                ? FileImage(avatarImage!)
                                : null,
                            child: avatarImage == null
                                ? Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Username + edit
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              username,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1F3C88),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.edit,
                              size: 18,
                              color: Color(0xFF1F3C88),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),
                        const Text(
                          "Lissu.pnk@gmail.com",
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // STATS ROW (Liittymispäivä / Hyvinvointiprofiili)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _infoCard("Liittymispäivä", "20.10.2025"),
                  _infoCard("Hyvinvointiprofiili", profileType ?? "Koala"),
                ],
              ),

              const SizedBox(height: 20),

              // SAAVUTUKSET TITLE
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  "Saavutukset",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              _achievementCard(),

              const SizedBox(height: 25),

              // Kyselyt TITLE
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  "Kyselyt",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              _surveyCard(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // SMALL ROUND CARDS (Liittymispäivä, Hyvinvointiprofiili)
  Widget _infoCard(String title, String value) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.blue.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // ACHIEVEMENTS CARD
  Widget _achievementCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                "Askelhaaste",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                "Näytä kaikki →",
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          _progressRow(Icons.flash_on, "Askelhaaste", 0.28),
          _progressRow(Icons.water_drop, "Juomahaaste", 0.35),
          _progressRow(Icons.local_fire_department, "Kirjautumisputki", 0.62),
        ],
      ),
    );
  }

  // PROGRESS BAR ITEM
  Widget _progressRow(IconData icon, String title, double progress) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade800, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: FractionallySizedBox(
                    widthFactor: progress,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "${(progress * 100).round()}% Valmis",
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // Kyselyt CARD
  Widget _surveyCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 12,
            right: 16,
            child: Text(
              "Näytä kaikki →",
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
