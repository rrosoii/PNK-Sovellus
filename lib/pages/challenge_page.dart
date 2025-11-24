import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChallengePage extends StatefulWidget {
  final String challengeId;
  final String title;
  final String description;
  final String type;
  final int durationDays;
  final int? requiredSteps;

  const ChallengePage({
    super.key,
    required this.challengeId,
    required this.title,
    required this.description,
    required this.type,
    required this.durationDays,
    this.requiredSteps,
  });

  @override
  State<ChallengePage> createState() => _ChallengePageState();
}

class _ChallengePageState extends State<ChallengePage> {
  bool loading = true;
  Map<String, dynamic>? activeChallenge;

  @override
  void initState() {
    super.initState();
    loadChallenge();
  }

  Future<void> loadChallenge() async {
    final user = FirebaseAuth.instance.currentUser!;
    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    final challenges = doc.data()?["activeChallenges"] ?? {};

    setState(() {
      activeChallenge = challenges[widget.challengeId];
      loading = false;
    });
  }

  Future<void> startChallenge() async {
    final user = FirebaseAuth.instance.currentUser!;
    final date = DateFormat("yyyy-MM-dd").format(DateTime.now());

    await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
      "activeChallenges": {
        widget.challengeId: {
          "isActive": true,
          "currentDay": 0,
          "durationDays": widget.durationDays,
          "startDate": date,
          "dailyProgress": {},
          "requiredSteps": widget.requiredSteps,
          "type": widget.type,
        }
      }
    }, SetOptions(merge: true));

    loadChallenge();
  }

  Future<void> cancelChallenge() async {
    final user = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
      "activeChallenges": {
        widget.challengeId: {"isActive": false}
      }
    }, SetOptions(merge: true));

    loadChallenge();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    const topBlue = Color(0xFFBFD5FF);
    const whiteBG = Color(0xFFEFF4FF);
    const textBlue = Color(0xFF485885);

    return Scaffold(
      backgroundColor: topBlue,
      body: SafeArea(
        child: Stack(
          children: [
            // Back button
            Positioned(
              top: 10,
              left: 10,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),

            // Main content scroll
            SingleChildScrollView(
              child: Column(
                children: [
                  // curved top bubble
                  const SizedBox(height: 80),
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(140),
                    ),
                    child: Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.88,
                      color: whiteBG,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: textBlue,
                              ),
                            ),
                            const SizedBox(height: 10),

                            Text(
                              widget.description,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 40),

                            // If inactive
                            if (activeChallenge == null ||
                                activeChallenge?["isActive"] != true)
                              _buildStartButton(),

                            // If active
                            if (activeChallenge?["isActive"] == true)
                              _buildActiveUI(context),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return ElevatedButton(
      onPressed: startChallenge,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF437BD2),
        foregroundColor: Colors.white,
        minimumSize: const Size(200, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text("Aloita", style: TextStyle(fontSize: 18)),
    );
  }

  Widget _buildActiveUI(BuildContext context) {
    const textBlue = Color(0xFF485885);

    final todayKey = DateFormat("yyyy-MM-dd").format(DateTime.now());
    final stepsToday = activeChallenge?["dailyProgress"]?[todayKey] ?? 0;

    final requiredSteps = widget.requiredSteps ?? 10000;

    final dailyProgress = (stepsToday / requiredSteps).clamp(0.0, 1.0);

    final currentDay = activeChallenge?["currentDay"] ?? 0;
    final totalDays = activeChallenge?["durationDays"] ?? widget.durationDays;

    final totalProgress = (currentDay + dailyProgress) / totalDays;

    return Column(
      children: [
        const Text(
          "Melkein valmis!",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textBlue,
          ),
        ),
        const SizedBox(height: 30),

        // Gradient progress bar
        _buildProgressBar(totalProgress),

        const SizedBox(height: 25),

        Text(
          "${(totalProgress * 100).toInt()}%",
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: textBlue,
          ),
        ),

        const SizedBox(height: 40),

        ElevatedButton(
          onPressed: cancelChallenge,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF437BD2),
            foregroundColor: Colors.white,
            minimumSize: const Size(200, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text("Keskeytä haaste", style: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }

  Widget _buildProgressBar(double progress) {
    return Container(
      height: 25,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFFDDE7F7),
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF3D78FF),
                    Color(0xFF6CC4A1),
                    Color(0xFFBFD5FF),
                  ],
                  stops: [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
