import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pnksovellus/pages/challenge_page.dart';

class AllChallengesPage extends StatefulWidget {
  final List<Map<String, dynamic>> challenges;

  const AllChallengesPage({super.key, required this.challenges});

  @override
  State<AllChallengesPage> createState() => _AllChallengesPageState();
}

class _AllChallengesPageState extends State<AllChallengesPage> {
  List<Map<String, dynamic>> _challengeData = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadChallenges();
  }

  Future<void> _loadChallenges() async {
    final defaults = _defaults();
    final merged = <String, Map<String, dynamic>>{
      for (final entry in defaults.entries) entry.key: {...entry.value},
    };

    // merge incoming prop (from profile/wherever)
    for (final c in widget.challenges) {
      final id = (c["id"] ?? "") as String;
      if (id.isEmpty) continue;
      merged[id] = {...defaults[id] ?? {}, ...c, "id": id};
    }

    // merge live data from Firestore so active challenges started elsewhere show up
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .get();
        final active = (doc.data()?["activeChallenges"] ?? {}) as Map?;
        if (active != null) {
          active.forEach((id, value) {
            if (value is Map) {
              final progress = (value["progress"] as num?)?.toDouble() ?? 0.0;
              final currentDay =
                  (value["currentDay"] as num?)?.toDouble() ?? 0.0;
              merged[id] = {
                ...defaults[id] ?? {},
                ...value,
                "id": id,
                "isActive": value["isActive"] == true,
                "isDone": value["isDone"] == true,
                "progress": progress > 0 ? progress : currentDay,
              };
            }
          });
        }
      } catch (_) {
        // ignore errors, keep merged defaults/prop
      }
    }

    setState(() {
      _challengeData = merged.values.toList();
      _loading = false;
    });
  }

  Map<String, Map<String, dynamic>> _defaults() {
    return {
      "steps_10000_week": {
        "id": "steps_10000_week",
        "title": "Kävelyhaaste",
        "icon": Icons.directions_walk,
        "isDone": false,
        "isActive": false,
        "progress": 0.0,
        "description": "Kulje 10 000 askelta päivittäin viikon ajan.",
        "type": "steps",
        "durationDays": 7,
        "requiredSteps": 10000,
      },
      "exercise_daily_14": {
        "id": "exercise_daily_14",
        "title": "Liiku jokapäivä",
        "icon": Icons.fitness_center,
        "isDone": false,
        "isActive": false,
        "progress": 0.0,
        "description": "Tee liikuntasuoritus joka päivä 14 päivän ajan.",
        "type": "exercise",
        "durationDays": 14,
        "requiredSteps": 14,
      },
      "exercise_weekly_5": {
        "id": "exercise_weekly_5",
        "title": "Liiku aktiivisesti",
        "icon": Icons.run_circle_outlined,
        "isDone": false,
        "isActive": false,
        "progress": 0.0,
        "description": "Liiku monipuolisesti 5 kertaa viikossa.",
        "type": "exerciseWeekly",
        "durationDays": 7,
        "requiredSteps": 5,
      },
      "steps_100k_month": {
        "id": "steps_100k_month",
        "title": "100 000 askelta",
        "icon": Icons.flag,
        "isDone": false,
        "isActive": false,
        "progress": 0.0,
        "description": "Kerää 100 000 askelta kuukauden aikana.",
        "type": "stepsAccumulated",
        "durationDays": 30,
        "requiredSteps": 100000,
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final normalized = _challengeData.map((c) {
      final progress = (c["progress"] as double? ?? 0.0);
      final currentDay = (c["currentDay"] as num?)?.toDouble() ?? 0.0;
      final bool isDone = c["isDone"] == true;
      final bool isActive =
          c["isActive"] == true || (!isDone && (progress > 0 || currentDay > 0));
      return {
        ...c,
        "isActive": isActive,
        "isDone": isDone,
        "progress": progress.clamp(0.0, 1.0),
      };
    }).toList();

    final done = normalized.where((c) => c["isDone"] == true).toList();
    final active =
        normalized.where((c) => c["isActive"] == true && c["isDone"] != true).toList();
    final notStarted = normalized
        .where((c) =>
            c["isDone"] != true &&
            c["isActive"] != true &&
            ((c["progress"] as double? ?? 0.0) <= 0.0))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFE7F0FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F3C88),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
        title: const Text("Haasteet"),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadChallenges,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader("Keskeneräiset"),
                const SizedBox(height: 10),
                if (active.isEmpty)
                  _emptyState("Ei keskeneräisiä haasteita juuri nyt.")
                else
                  ...active.map(
                    (c) => _challengeTile(
                      context,
                      c,
                      completed: false,
                    ),
                  ),
                const SizedBox(height: 24),
                _sectionHeader("Valmiit"),
                const SizedBox(height: 10),
                if (done.isEmpty)
                  _emptyState("Ei suoritettuja haasteita vielä.")
                else
                  ...done.map(
                    (c) => _challengeTile(
                      context,
                      c,
                      completed: true,
                    ),
                  ),
                const SizedBox(height: 24),
                _sectionHeader("Tekemättömät haasteet"),
                const SizedBox(height: 10),
                if (notStarted.isEmpty)
                  _emptyState("Ei uusia aloittamattomia haasteita.")
                else
                  ...notStarted.map(
                    (c) => _challengeTile(
                      context,
                      c,
                      completed: false,
                      tappable: true,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF1F3C88),
          fontWeight: FontWeight.w800,
          fontSize: 16,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _emptyState(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.black54),
      ),
    );
  }

  Widget _challengeTile(
    BuildContext context,
    Map<String, dynamic> data, {
    required bool completed,
    bool tappable = false,
  }) {
    final icon = data["icon"] as IconData? ?? Icons.flag;
    final title = data["title"] as String? ?? data["id"] as String? ?? "";
    final description =
        data["description"] as String? ?? "Aloita haaste nyt ja seuraa etenemistäsi.";
    final double progress =
        completed ? 1.0 : (data["progress"] as double? ?? 0.0).clamp(0.0, 1.0);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: tappable
          ? () {
              final int duration =
                  (data["durationDays"] as int?) ?? (data["duration"] as int?) ?? 7;
              final int? requiredSteps = data["requiredSteps"] as int?;
              final int? targetCount = data["targetCount"] as int?;
              final String type = data["type"] as String? ?? "steps";

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChallengePage(
                    challengeId: data["id"] as String? ?? "",
                    title: title,
                    description: description,
                    type: type,
                    durationDays: duration,
                    requiredSteps: requiredSteps,
                    targetCount: targetCount,
                  ),
                ),
              ).then((_) => _loadChallenges());
            }
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: completed ? Colors.green.shade50 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: completed ? Colors.green.shade700 : Colors.blue.shade700,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: FractionallySizedBox(
                      widthFactor: progress,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          color: completed
                              ? Colors.green.shade600
                              : Colors.blue.shade700,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    completed
                        ? "Valmis"
                        : "${(progress * 100).round()}% valmis",
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            if (completed)
              Icon(
                Icons.check_circle,
                color: Colors.green.shade700,
              ),
          ],
        ),
      ),
    );
  }
}
