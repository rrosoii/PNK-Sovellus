import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:pnksovellus/services/achievement_service.dart';
import 'package:pnksovellus/pages/etusivu.dart';

class ChallengePage extends StatefulWidget {
  final String challengeId;
  final String title;
  final String description;
  final String type;
  final int durationDays;
  final int? requiredSteps;
  final int? targetCount;

  const ChallengePage({
    super.key,
    required this.challengeId,
    required this.title,
    required this.description,
    required this.type,
    required this.durationDays,
    this.requiredSteps,
    this.targetCount,
  });

  @override
  State<ChallengePage> createState() => _ChallengePageState();
}

class _ChallengePageState extends State<ChallengePage> {
  bool loading = true;
  Map<String, dynamic>? activeChallenge;
  String? _error;
  bool _alreadyAchieved = false;
  final AchievementService _achievementService = AchievementService();

  @override
  void initState() {
    super.initState();
    loadChallenge();
  }

  Future<void> loadChallenge() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        loading = false;
        _error = "Kirjaudu sisään aloittaaksesi haasteet.";
        activeChallenge = null;
      });
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      final challenges = doc.data()?["activeChallenges"] ?? {};
      final achievements = doc.data()?["achievements"] ?? {};

      setState(() {
        activeChallenge = challenges[widget.challengeId];
        _alreadyAchieved = achievements is Map &&
            achievements.keys.contains(widget.challengeId);
        loading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        loading = false;
        _error = "Haasteen lataus epäonnistui.";
      });
    }
  }

  Future<void> startChallenge() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kirjaudu sisään aloittaaksesi haasteet")),
      );
      return;
    }
    final date = DateFormat("yyyy-MM-dd").format(DateTime.now());
    final target = _defaultTarget();

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
          "target": target,
        }
      }
    }, SetOptions(merge: true));

    loadChallenge();
  }

  Future<void> cancelChallenge() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.pop(context);
      return;
    }
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

    if (_error != null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _goHome(),
                    child: const Text("Takaisin"),
                  )
                ],
              ),
            ),
          ),
        ),
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

            // Back button on top of scroll content
            Positioned(
              top: 10,
              left: 10,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _goHome,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
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

    final totalProgress = _calculateProgress();
    _maybeAward(totalProgress);
    final statusText = _statusText(totalProgress);
    final detail = _progressDetail();

    return Column(
      children: [
        Text(
          statusText,
          style: const TextStyle(
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

        const SizedBox(height: 12),
        Text(
          detail,
          style: const TextStyle(color: Colors.black54),
          textAlign: TextAlign.center,
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

  int _defaultTarget() {
    switch (widget.type) {
      case "exerciseWeekly":
        return widget.targetCount ?? widget.requiredSteps ?? 5;
      case "exercise":
        return widget.targetCount ??
            widget.requiredSteps ??
            widget.durationDays;
      case "stepsAccumulated":
        return widget.requiredSteps ?? 100000;
      case "steps":
      default:
        return widget.requiredSteps ?? 10000;
    }
  }

  double _calculateProgress() {
    if (activeChallenge == null) return 0;
    final type = activeChallenge?["type"] as String? ?? widget.type;
    final start = DateTime.tryParse(activeChallenge?["startDate"] ?? "") ??
        DateTime.now();
    final duration = activeChallenge?["durationDays"] ?? widget.durationDays;
    final target = activeChallenge?["target"] ?? _defaultTarget();
    final daily = Map<String, dynamic>.from(
      activeChallenge?["dailyProgress"] as Map<String, dynamic>? ?? {},
    );
    final end = start.add(Duration(days: duration));

    double progress = 0;

    switch (type) {
      case "stepsAccumulated":
        final totalSteps = _entriesInRange(daily, start, end).fold<int>(
          0,
          (prev, entry) =>
              prev +
              ((entry.value is num)
                  ? (entry.value as num).toInt()
                  : int.tryParse("${entry.value}") ?? 0),
        );
        progress = (totalSteps / target).clamp(0.0, 1.0);
        break;
      case "exerciseWeekly":
      case "exercise":
        final totalSessions = _entriesInRange(daily, start, end).fold<int>(
          0,
          (prev, entry) =>
              prev +
              ((entry.value is num)
                  ? (entry.value as num).toInt()
                  : int.tryParse("${entry.value}") ?? 0),
        );
        progress = (totalSessions / target).clamp(0.0, 1.0);
        break;
      case "steps":
      default:
        final perDaySum = _entriesInRange(daily, start, end).fold<double>(
          0,
          (prev, entry) {
            final steps = (entry.value is num)
                ? (entry.value as num).toDouble()
                : double.tryParse("${entry.value}") ?? 0;
            return prev + (steps / target).clamp(0.0, 1.0);
          },
        );
        progress = (perDaySum / duration).clamp(0.0, 1.0);
        break;
    }

    return progress;
  }

  String _statusText(double progress) {
    if (activeChallenge == null) return "Aloita haaste";
    final start = DateTime.tryParse(activeChallenge?["startDate"] ?? "") ??
        DateTime.now();
    final duration = activeChallenge?["durationDays"] ?? widget.durationDays;
    final end = start.add(Duration(days: duration));

    if (progress >= 1.0) {
      return "Haaste suoritettu!";
    }

    if (DateTime.now().isAfter(end)) {
      return "Haaste päättynyt";
    }

    return "Haaste käynnissä";
  }

  String _progressDetail() {
    if (activeChallenge == null) return "";
    final type = activeChallenge?["type"] as String? ?? widget.type;
    final target = activeChallenge?["target"] ?? _defaultTarget();
    final daily = Map<String, dynamic>.from(
      activeChallenge?["dailyProgress"] as Map<String, dynamic>? ?? {},
    );
    final start = DateTime.tryParse(activeChallenge?["startDate"] ?? "") ??
        DateTime.now();
    final duration = activeChallenge?["durationDays"] ?? widget.durationDays;
    final end = start.add(Duration(days: duration));
    final entries = _entriesInRange(daily, start, end);

    switch (type) {
      case "stepsAccumulated":
        final totalSteps = entries.fold<int>(
          0,
          (prev, entry) =>
              prev +
              ((entry.value is num)
                  ? (entry.value as num).toInt()
                  : int.tryParse("${entry.value}") ?? 0),
        );
        return "$totalSteps / $target askelta";
      case "exerciseWeekly":
      case "exercise":
        final totalSessions = entries.fold<int>(
          0,
          (prev, entry) =>
              prev +
              ((entry.value is num)
                  ? (entry.value as num).toInt()
                  : int.tryParse("${entry.value}") ?? 0),
        );
        return "$totalSessions / $target suoritusta";
      case "steps":
      default:
        final daysHit = entries
            .map((entry) => (entry.value is num)
                ? (entry.value as num).toDouble()
                : double.tryParse("${entry.value}") ?? 0)
            .where((v) => v >= target)
            .length;
        return "$daysHit / ${activeChallenge?["durationDays"] ?? widget.durationDays} päivää saavutettu";
    }
  }

  Iterable<MapEntry<String, dynamic>> _entriesInRange(
      Map<String, dynamic> daily, DateTime start, DateTime end) {
    return daily.entries.where((e) {
      final d = DateTime.tryParse(e.key);
      if (d == null) return false;
      return !d.isBefore(start) && !d.isAfter(end);
    });
  }

  void _goHome() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Etusivu()),
      );
    }
  }

  void _maybeAward(double progress) {
    if (_alreadyAchieved) return;
    if (progress >= 1.0) {
      _alreadyAchieved = true;
      _achievementService.award(widget.challengeId, widget.title);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Saavutus ansaittu!")),
      );
    }
  }
}
