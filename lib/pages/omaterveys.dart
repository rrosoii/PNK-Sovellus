// ignore_for_file: unused_local_variable, deprecated_member_use, prefer_const_constructors, prefer_const_declarations, unused_element, curly_braces_in_flow_control_structures, use_build_context_synchronously, unnecessary_import, unused_element_parameter, unnecessary_null_comparison

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pnksovellus/pages/asetukset.dart';
import 'package:pnksovellus/services/user_data_service.dart';
import 'package:pnksovellus/widgets/app_bottom_nav.dart';

final IconData defaultCustomIcon = Icons.star;

// Global activity icons map for use in multiple widgets
final Map<String, IconData> activityIcons = {
  "Juoksu": Icons.directions_run,
  "Pyöräily": Icons.pedal_bike,
  "Kävely": Icons.directions_walk,
  "Kuntosali": Icons.fitness_center,
  "Jooga": Icons.self_improvement,
};

class Omaterveys extends StatelessWidget {
  const Omaterveys({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const TrackerPage(),
    );
  }
}

bool showExercises = false;
final ScrollController _exerciseCardScroll = ScrollController();

class _CalendarHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _CalendarHeaderDelegate({required this.child});

  @override
  double get minExtent => 0;
  @override
  double get maxExtent => 320; // your calendar height

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Stack(children: [Positioned.fill(child: child)]);
  }

  @override
  bool shouldRebuild(_CalendarHeaderDelegate oldDelegate) {
    return false;
  }
}

class TrackerPage extends StatefulWidget {
  const TrackerPage({super.key});

  @override
  State<TrackerPage> createState() => _TrackerPageState();
}

final ScrollController _exerciseScroll = ScrollController();

class _TrackerPageState extends State<TrackerPage> {
  int waterGlasses = 0;
  Map<int, int> waterMap = {};

  late StreamSubscription<StepCount>? _stepSub;

  // Health / step tracking
  int todaySteps = 0;
  double todayDistanceKm = 0;
  double todayCalories = 0;

  int selectedMood = 2;
  Map<int, int> moodMap = {};

  late DateTime currentMonth;
  int selectedDay = DateTime.now().day;

  // per-day exercises for the current month: day -> list of {type, duration, distance}
  Map<int, List<Map<String, String>>> exerciseLog = {};

  // persisted custom activities (shared with AddExerciseSheet)
  List<String> customActivities = [];
  final UserDataService _dataService = UserDataService();

  // REAL WORKING ICON LIST
  final moodIcons = [
    'assets/icons/sadlissu.png',
    'assets/icons/lissufaded.png',
    'assets/icons/lissuhappy.png',
  ];

  @override
  void initState() {
    super.initState();
    currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    _loadMoodData();
    _loadWaterData();
    _loadExerciseData();
    _loadCustomActivities();
    _startStepTracking();
  }

  @override
  void dispose() {
    _stepSub?.cancel();
    super.dispose();
  }

  double _distanceFromSteps(int steps) {
    // rough average: 0.78 m per step
    return (steps * 0.78) / 1000.0; // km
  }

  double _caloriesFromSteps(int steps) {
    // very rough: ~0.04 kcal per step
    return steps * 0.04;
  }

  bool _isFutureDay(int day) {
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final thisDay = DateTime(currentMonth.year, currentMonth.month, day);
    return thisDay.isAfter(todayDate);
  }

  Future<void> _loadCustomActivities() async {
    customActivities = await _dataService.loadCustomActivities();
    setState(() {});
  }

  Future<void> _saveCustomActivities() async {
    await _dataService.saveCustomActivities(customActivities);
  }

  Future<void> _loadWaterData() async {
    if (!isLoggedIn) {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_waterLocalKey(currentMonth)) ??
          prefs.getString(_legacyWaterKey(currentMonth));

      if (saved == null || saved.isEmpty) {
        setState(() {
          waterMap = {};
          waterGlasses = 0;
        });
        return;
      }

      final mm = <int, int>{};
      for (var p in saved.split(",")) {
        if (p.contains(":")) {
          final s = p.split(":");
          mm[int.parse(s[0])] = int.parse(s[1]);
        }
      }

      setState(() {
        waterMap = mm;
        waterGlasses = waterMap[selectedDay] ?? 0;
      });
      return;
    }

    try {
      final docId = "water_${_monthId(currentMonth)}";
      final doc = await _userHealthColl!.doc(docId).get();
      final data = doc.data();
      final mm = <int, int>{};
      if (data != null && data['map'] is Map) {
        (data['map'] as Map).forEach((k, v) {
          mm[int.parse(k.toString())] = int.parse(v.toString());
        });
      }
      setState(() {
        waterMap = mm;
        waterGlasses = waterMap[selectedDay] ?? 0;
      });
    } catch (e) {
      debugPrint("Failed to load water from Firestore: $e");
      setState(() {
        waterMap = {};
        waterGlasses = 0;
      });
    }
  }

  Future<void> _saveWaterData() async {
    if (!isLoggedIn) {
      final prefs = await SharedPreferences.getInstance();
      final enc = waterMap.entries.map((e) => "${e.key}:${e.value}").join(",");
      prefs.setString(_waterLocalKey(currentMonth), enc);
      return;
    }

    try {
      final docId = "water_${_monthId(currentMonth)}";
      await _userHealthColl!.doc(docId).set(
          {'map': waterMap.map((k, v) => MapEntry(k.toString(), v))},
          SetOptions(merge: true));
    } catch (e) {
      debugPrint("Failed to save water to Firestore: $e");
    }
  }

  Future<void> _startStepTracking() async {
    final status = await Permission.activityRecognition.request();

    if (!status.isGranted) {
      debugPrint("Step permission denied");
      return;
    }

    _stepSub = Pedometer.stepCountStream.listen(
      (event) {
        setState(() {
          todaySteps = event.steps;
          todayDistanceKm = _distanceFromSteps(todaySteps);
          todayCalories = _caloriesFromSteps(todaySteps);
        });
        _dataService.recordStepsForDate(DateTime.now(), todaySteps);
      },
      onError: (e) => debugPrint("Pedometer error: $e"),
    );
  }

  // ========================= DECORATIVE BALLS =========================

  Widget _decorBalls() {
    return IgnorePointer(
      ignoring: true,
      child: Stack(
        children: [
          Positioned(
            top: -150,
            left: -120,
            child: Container(
              width: 260,
              height: 260,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromRGBO(46, 90, 172, 0.23),
              ),
            ),
          ),
          Positioned(
            top: -90,
            left: 50,
            child: Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromRGBO(46, 90, 172, 0.16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========================= NOTIFICATIONS + SETTINGS =========================

  Widget _buildTopButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications,
                    color: Colors.blue,
                    size: 25,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Ilmoitukset avattu")),
                    );
                  },
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            PopupMenuButton<int>(
              icon: const Icon(Icons.settings, color: Colors.blue, size: 25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.white,
              offset: const Offset(0, 40),
              onSelected: (value) {
                if (value == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AsetuksetPage(),
                    ),
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_outline, color: Color(0xFF485885)),
                      SizedBox(width: 10),
                      Text(
                        "Profiili",
                        style: TextStyle(color: Color(0xFF485885)),
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.settings_outlined, color: Color(0xFF485885)),
                      SizedBox(width: 10),
                      Text(
                        "Asetukset",
                        style: TextStyle(color: Color(0xFF485885)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ========================= DATA SAVE/LOAD =========================

  String _monthId(DateTime date) =>
      "${date.year}_${date.month.toString().padLeft(2, '0')}";
  String _moodLocalKey(DateTime date) => "moods_${_monthId(date)}";
  String _exerciseLocalKey(DateTime date) => "exercise_${_monthId(date)}";
  String _waterLocalKey(DateTime date) => "water_${_monthId(date)}";
  String _legacyMoodKey(DateTime date) => "moods_${date.year}_${date.month}";
  String _legacyExerciseKey(DateTime date) =>
      "exercise_${date.year}_${date.month}";
  String _legacyWaterKey(DateTime date) => "water_${date.year}_${date.month}";
  String _monthKey(DateTime date) =>
      "${date.year}_${date.month.toString().padLeft(2, '0')}";
  String _exerciseKey(DateTime date) => "exercise_${_monthId(date)}";

  bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;
  CollectionReference<Map<String, dynamic>>? get _userHealthColl => _uid == null
      ? null
      : FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .collection('health');

  Future<void> _loadMoodData() async {
    if (!isLoggedIn) {
      final saved = await _dataService.loadMoodData(_monthKey(currentMonth));
      if (saved == null || saved.isEmpty) {
        setState(() => moodMap = {});
        return;
      }

      final pairs = saved.split(",");
      final mm = <int, int>{};
      for (var p in pairs) {
        if (p.contains(":")) {
          final s = p.split(":");
          mm[int.parse(s[0])] = int.parse(s[1]);
        }
      }

      setState(() => moodMap = mm);
      return;
    }

    try {
      final docId = "moods_${_monthId(currentMonth)}";
      final doc = await _userHealthColl!.doc(docId).get();
      final data = doc.data();
      final mm = <int, int>{};
      if (data != null && data['map'] is Map) {
        (data['map'] as Map).forEach((k, v) {
          mm[int.parse(k.toString())] = int.parse(v.toString());
        });
      }
      setState(() => moodMap = mm);
    } catch (e) {
      debugPrint("Failed to load moods from Firestore: $e");
      setState(() => moodMap = {});
    }
  }

  Future<void> _saveMoodData() async {
    final enc = moodMap.entries.map((e) => "${e.key}:${e.value}").join(",");
    await _dataService.saveMoodData(_monthKey(currentMonth), enc);
  }

  Future<void> _loadExerciseData() async {
    if (!isLoggedIn) {
      final raw = await _dataService.loadExerciseData(_exerciseKey(currentMonth));
      if (raw == null || raw.isEmpty) {
        setState(() => exerciseLog = {});
        return;
      }

      final Map<int, List<Map<String, String>>> temp = {};
      for (var item in raw.split("&")) {
        final parts = item.split("|");
        if (parts.length != 4) continue;
        final day = int.tryParse(parts[0]);
        if (day == null) continue;

        temp.putIfAbsent(day, () => []);
        temp[day]!.add({
          "type": parts[1],
          "duration": parts[2],
          "distance": parts[3],
        });
      }

      setState(() => exerciseLog = temp);
      return;
    }

    try {
      final docId = "exercise_${_monthId(currentMonth)}";
      final doc = await _userHealthColl!.doc(docId).get();
      final data = doc.data();
      final raw = data != null ? data['raw'] as String? : null;

      if (raw == null || raw.isEmpty) {
        setState(() => exerciseLog = {});
        return;
      }

      final Map<int, List<Map<String, String>>> temp = {};
      for (var item in raw.split("&")) {
        final parts = item.split("|");
        if (parts.length != 4) continue;
        final day = int.tryParse(parts[0]);
        if (day == null) continue;

        temp.putIfAbsent(day, () => []);
        temp[day]!.add({
          "type": parts[1],
          "duration": parts[2],
          "distance": parts[3],
        });
      }

      setState(() => exerciseLog = temp);
    } catch (e) {
      debugPrint("Failed to load exercises from Firestore: $e");
      setState(() => exerciseLog = {});
    }
  }

  Future<void> _saveExerciseData() async {
    final List<String> encoded = [];

    exerciseLog.forEach((day, list) {
      for (var e in list) {
        final type = e['type'] ?? '';
        final duration = e['duration'] ?? '';
        final distance = e['distance'] ?? '';
        encoded.add("$day|$type|$duration|$distance");
      }
    });

    await _dataService.saveExerciseData(
      _exerciseKey(currentMonth),
      encoded.join("&"),
    );
  }

  Future<void> _recordExerciseForChallenges() async {
    final date = DateTime(currentMonth.year, currentMonth.month, selectedDay);
    await _dataService.recordExerciseForDate(date, count: 1);
  }

  void _prevMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month - 1, 1);
    });
    _loadMoodData();
    _loadWaterData();
    _loadExerciseData();
  }

  void _nextMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
    });
    _loadMoodData();
    _loadWaterData();
    _loadExerciseData();
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return Scaffold(
      backgroundColor: const Color(0xFFE8F0FF),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildTopPart(today),
                Expanded(
                  child: Stack(
                    children: [
                      // ===================== CALENDAR =====================
                      Positioned.fill(
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              _buildCalendarCard(),
                              const SizedBox(height: 20),

                              // ------- TOGGLE BUTTON -------
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    showExercises = true;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 12,
                                        color: Colors.black.withOpacity(0.08),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Text(
                                        "Näytä liikuntasuoritukset",
                                        style: TextStyle(
                                          color: Color(0xFF233A72),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.keyboard_arrow_up,
                                          color: Color(0xFF233A72)),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 120),
                            ],
                          ),
                        ),
                      ),

                      // ===================== EXERCISE CARD POPUP =====================
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutCubic,

                        // if visible → slide up over calendar
                        // if hidden → slide fully offscreen bottom
                        bottom: showExercises ? 0 : -500,
                        left: 0,
                        right: 0,

                        child: Container(
                          padding: const EdgeInsets.only(top: 12),
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                          child: Column(
                            children: [
                              // ---- DRAG HANDLE / HIDE BUTTON ----
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    showExercises = false;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 12,
                                        color: Colors.black.withOpacity(0.08),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Text(
                                        "Piilota",
                                        style: TextStyle(
                                          color: Color(0xFF233A72),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.keyboard_arrow_down,
                                          color: Color(0xFF233A72)),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              // ---- EXERCISE CARD ITSELF ----
                              Container(
                                height: 350,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 12,
                                      color: Colors.black.withOpacity(0.08),
                                    ),
                                  ],
                                ),
                                child: ListView(
                                  controller: _exerciseCardScroll,
                                  padding: EdgeInsets.zero,
                                  children: [
                                    _buildExerciseCard(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            _decorBalls(),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }

  // ========================= TOP PART =========================

  Widget _buildTopPart(DateTime today) {
    return Column(
      children: [
        const SizedBox(height: 10),
        _buildTopButtons(),
        const SizedBox(height: 10),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Hei, miten tänään liikutaan?",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF233A72),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _buildWaterAndMoods(today),
        const SizedBox(height: 8),
        _buildStepArc(),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildWaterAndMoods(DateTime today) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // minus button
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (waterGlasses > 0) waterGlasses--;
                    if (waterGlasses > 0) {
                      waterMap[selectedDay] = waterGlasses;
                    } else {
                      waterMap.remove(selectedDay);
                    }
                  });
                  _saveWaterData();
                },
                child: Icon(
                  Icons.remove_circle_outline,
                  size: 30,
                  color: const Color(0xFF233A72),
                ),
              ),

              const SizedBox(width: 3),

              // water glass with glow
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 18,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      "assets/icons/waterglass.png",
                      width: 65,
                      height: 80,
                    ),
                    Transform.translate(
                      offset: const Offset(
                          0, 16), // move down; adjust value to taste
                      child: Text(
                        "$waterGlasses",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 3),

              // plus button
              GestureDetector(
                onTap: () {
                  setState(() {
                    waterGlasses++;
                    waterMap[selectedDay] = waterGlasses;
                  });
                  _saveWaterData();
                },
                child: Icon(
                  Icons.add_circle_outline,
                  size: 30,
                  color: const Color(0xFF233A72),
                ),
              ),
            ],
          ),

          // moods + clear
          // moods (tap same mood again to clear)
          Row(
            children: List.generate(3, (i) {
              final bool isSelectedForDay = moodMap[selectedDay] == i;

              return GestureDetector(
                onTap: () {
                  if (_isFutureDay(selectedDay)) return;
                  setState(() {
                    if (moodMap[selectedDay] == i) {
                      // tap same mood again -> clear it
                      moodMap.remove(selectedDay);
                      selectedMood = -1;
                    } else {
                      // set mood
                      moodMap[selectedDay] = i;
                      selectedMood = i;
                    }
                  });
                  _saveMoodData();
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  padding: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelectedForDay
                        ? Colors.white.withOpacity(0.5)
                        : Colors.transparent,
                    boxShadow: isSelectedForDay
                        ? [
                            BoxShadow(
                              color: const Color.fromARGB(255, 255, 255, 255)
                                  .withOpacity(0.55),
                              blurRadius: 30,
                              spreadRadius: 6,
                            ),
                          ]
                        : [],
                  ),
                  child: Image.asset(
                    moodIcons[i],
                    width: 65,
                    height: 65,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStepArc() {
    // fallback: if health didn't work, stay with some default
    final int displaySteps =
        todaySteps; // or todaySteps == 0 ? steps : todaySteps;

    return SizedBox(
      height: 170,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          CustomPaint(
            painter: StepArcPainter(steps: displaySteps),
            child: SizedBox(
              height: 150,
              width: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "$displaySteps",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF233A72),
                    ),
                  ),
                  const Text(
                    "/ 10000",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            left: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Matka",
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                Text(
                  "${todayDistanceKm.toStringAsFixed(2)} km",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF233A72),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 4,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  "Energia",
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                Text(
                  "${todayCalories.toStringAsFixed(0)} kcal",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF233A72),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========================= CALENDAR =========================

  Widget _buildCalendarCard() {
    final today = DateTime.now();
    final firstDay = currentMonth;
    final daysInMonth = DateTime(
      currentMonth.year,
      currentMonth.month + 1,
      0,
    ).day;
    final startWeekday = firstDay.weekday;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _prevMonth,
                child: const Icon(Icons.chevron_left,
                    size: 26, color: Color(0xFF6F85C2)),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    DateFormat("LLLL yyyy", "fi_FI").format(currentMonth),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF233A72),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: _nextMonth,
                child: const Icon(Icons.chevron_right,
                    size: 26, color: Color(0xFF6F85C2)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ["Ma", "Ti", "Ke", "To", "Pe", "La", "Su"]
                .map(
                  (d) => Text(
                    d,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daysInMonth + (startWeekday - 1),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemBuilder: (_, index) {
              if (index < startWeekday - 1) return Container();

              final day = index - (startWeekday - 2);

              final bool isFuture = _isFutureDay(day);
              final isToday = today.year == currentMonth.year &&
                  today.month == currentMonth.month &&
                  today.day == day;

              final isSelected = day == selectedDay;

              // load mood for this day
              final int? mood = moodMap[day];
              Color moodColor = Colors.transparent;

              if (mood != null) {
                switch (mood) {
                  case 0:
                    moodColor = Colors.blue.withOpacity(0.3);
                    break;
                  case 1:
                    moodColor = Colors.grey.withOpacity(0.3);
                    break;
                  case 2:
                    moodColor = Colors.green.withOpacity(0.3);
                    break;
                }
              }

              // load exercise icons
              final hasExercises =
                  exerciseLog[day] != null && exerciseLog[day]!.isNotEmpty;

              final List<IconData> dayIcons = hasExercises
                  ? exerciseLog[day]!
                      .map((e) => activityIcons[e['type']] ?? defaultCustomIcon)
                      .toList()
                  : [];

              // background layer (mood > today > selected)
              Color bgColor = moodColor;
              if (isToday) bgColor = const Color(0xFFCCE0FF);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDay = day;
                    if (moodMap.containsKey(day)) {
                      selectedMood = moodMap[day]!;
                    } else {
                      selectedMood = -1; // no mood for this day
                    }
                    waterGlasses = waterMap[day] ?? 0;
                  });
                },
                onLongPress: () {
                  if (selectedMood < 0 || isFuture)
                    return; // nothing to apply / future locked
                  setState(() {
                    moodMap[day] = selectedMood;
                  });
                  _saveMoodData();
                },
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: bgColor, // apply mood/today tint (set above)
                    borderRadius: BorderRadius.circular(50),
                    border: isSelected
                        ? Border.all(color: const Color(0xFF5A8FF7), width: 2)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // day number
                      Text(
                        "$day",
                        style: TextStyle(
                          fontWeight:
                              isToday ? FontWeight.bold : FontWeight.normal,
                          color: isToday
                              ? const Color(0xFF0B3D91)
                              : Colors.black87,
                        ),
                      ),

                      // =============== ICONS FOR ACTIVITIES ===============
                      if (dayIcons.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 1,
                            children: dayIcons.take(3).map((ico) {
                              return Icon(
                                ico,
                                size: 10,
                                color: const Color(0xFF2E5AAC),
                              );
                            }).toList(),
                          ),
                        ),

                      if (dayIcons.length > 3)
                        const Icon(Icons.more_horiz,
                            size: 10, color: Color(0xFF2E5AAC)),
                    ],
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _addExerciseButton() {
    return Center(
      child: GestureDetector(
        onTap: () async {
          // OPEN THE SHEET AND WAIT FOR RESULT
          final result = await showModalBottomSheet<Map<String, String>>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => AddExerciseSheet(),
          );

          if (result != null) {
            setState(() {
              exerciseLog.putIfAbsent(selectedDay, () => []);
              exerciseLog[selectedDay]!.add(result);
            });
            _saveExerciseData();
            _recordExerciseForChallenges();
          }
        },
        child: Container(
          height: 65,
          width: 65,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.2),
                blurRadius: 12,
              ),
            ],
          ),
          child: const Icon(
            Icons.add,
            size: 34,
            color: Color(0xFF2E5AAC),
          ),
        ),
      ),
    );
  }

  // ========================= EXERCISES =========================

  Widget _buildExerciseCard() {
    final logsForDay = exerciseLog[selectedDay] ?? [];
    final count = logsForDay.length;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$count liikuntasuoritusta",
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF233A72),
            ),
          ),

          // dynamic list
          ...logsForDay.asMap().entries.map((entry) {
            final index = entry.key;
            final e = entry.value;

            return _buildDismissibleExercise(
              index: index,
              name: e['type'] ?? '',
              time: e['duration'] ?? '',
              dist: e['distance'] ?? '',
            );
          }).toList(),

          // Auto-create exercise from today's steps
          if (todaySteps > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Center(
                child: TextButton.icon(
                  onPressed: () {
                    final now = DateTime.now();

                    final autoEntry = <String, String>{
                      "type": "Kävely",
                      "duration": "0:30:00",
                      "distance": todayDistanceKm.toStringAsFixed(2),
                      "kcal": todayCalories.toStringAsFixed(0),
                      "start": "${now.hour.toString().padLeft(2, '0')}"
                          "."
                          "${now.minute.toString().padLeft(2, '0')}",
                    };

                    setState(() {
                      exerciseLog.putIfAbsent(selectedDay, () => []);
                      exerciseLog[selectedDay]!.add(autoEntry);
                    });
                    _saveExerciseData();
                    _recordExerciseForChallenges();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Päivän askelista luotu suoritus"),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.directions_walk,
                      color: Color(0xFF2E5AAC)),
                  label: const Text(
                    "Luo suoritus päivän askelista",
                    style: TextStyle(
                      color: Color(0xFF2E5AAC),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 10),

          // ---------------------- ADDED + BUTTON ----------------------
          Center(
            child: GestureDetector(
              onTap: () async {
                final result = await showModalBottomSheet<Map<String, String>>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => AddExerciseSheet(),
                );

                if (result != null) {
                  setState(() {
                    exerciseLog.putIfAbsent(selectedDay, () => []);
                    exerciseLog[selectedDay]!.add(result);
                  });
                  _saveExerciseData();
                }
              },
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.25),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add,
                  size: 32,
                  color: Color(0xFF2E5AAC),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildDismissibleExercise({
    required int index,
    required String name,
    required String time,
    required String dist,
  }) {
    final IconData activityIcon = activityIcons[name] ?? defaultCustomIcon;

    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,

      // --- prettier swipe background ---
      background: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            margin: const EdgeInsets.only(
              bottom: 10,
            ), // matches exercise tile spacing
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            decoration: BoxDecoration(
              color: const Color(0xFFE44A4A),
              borderRadius: BorderRadius.circular(14), // same as your list tile
            ),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.delete_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          );
        },
      ),

      // ---- confirmation popup ----
      confirmDismiss: (_) async {
        bool? confirmDelete = await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (ctx) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 80,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 26,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                      color: Colors.black.withOpacity(0.08),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Poistetaanko suoritus?",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF233A72),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // icon bubble
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7F0FF),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        activityIcon,
                        size: 34,
                        color: const Color(0xFF2E5AAC),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 28),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text(
                            "Peruuta",
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE44A4A),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 26,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text(
                            "Poista",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );

        return confirmDelete ?? false;
      },

      // ---- deletion + undo ----
      onDismissed: (_) {
        final removedItem = exerciseLog[selectedDay]!.removeAt(index);
        _saveExerciseData();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${removedItem["type"]} poistettu",
              style: const TextStyle(fontSize: 15),
            ),
            duration: const Duration(seconds: 3),
            backgroundColor: const Color(0xFF2E5AAC),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            action: SnackBarAction(
              label: "Kumoa",
              textColor: Colors.white,
              onPressed: () {
                setState(() {
                  exerciseLog[selectedDay]!.insert(index, removedItem);
                });
                _saveExerciseData();
              },
            ),
          ),
        );
      },

      // main tile
      child: _buildExerciseItem(activityIcon, name, time, dist),
    );
  }

  Widget _buildExerciseItem(
    IconData icon,
    String name,
    String time,
    String dist,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 23,
            backgroundColor: const Color(0xFFE7F0FF),
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Color(0xFF233A72),
                ),
              ),
              Text(time, style: const TextStyle(color: Colors.black54)),
            ],
          ),
          const Spacer(),
          Text(
            dist,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF233A72),
            ),
          ),
        ],
      ),
    );
  }

}

// ========================= STEP ARC PAINTER =========================

class StepArcPainter extends CustomPainter {
  final int steps;
  StepArcPainter({required this.steps});

  @override
  void paint(Canvas canvas, Size size) {
    final double percent = (steps / 10000).clamp(0.0, 1.0);
    final center = Offset(size.width / 2, size.height * 0.70);
    final radius = size.width * 0.45;

    const double stroke = 25;

    final bg = Paint()
      ..color = const Color(0xFFDDE3F4)
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pr = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF5A8FF7), Color(0xFF2F4A91)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const start = math.pi * 0.9;
    const end = math.pi * 2.1;
    final arc = end - start;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      arc,
      false,
      bg,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      arc * percent,
      false,
      pr,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ========================= ADD EXERCISE SHEET =========================

// ========================= ADD EXERCISE SHEET =========================

class AddExerciseSheet extends StatefulWidget {
  const AddExerciseSheet({super.key});

  @override
  State<AddExerciseSheet> createState() => _AddExerciseSheetState();
}

class _AddExerciseSheetState extends State<AddExerciseSheet> {
  // Text controllers
  late TextEditingController titleController;
  late TextEditingController distanceController;
  late TextEditingController kcalController;

  // Activity
  String activity = "Juoksu";

  // Default activities
  final List<String> _defaultActivities = [
    "Juoksu",
    "Pyöräily",
    "Kävely",
    "Kuntosali",
    "Jooga",
  ];

  // User-added activities (persisted)
  List<String> customActivities = [];

  List<String> get allActivities => [
        ..._defaultActivities,
        ...customActivities,
      ];

  // Icons for known activities
  final Map<String, IconData> activityIcons = {
    "Juoksu": Icons.directions_run,
    "Pyöräily": Icons.pedal_bike,
    "Kävely": Icons.directions_walk,
    "Kuntosali": Icons.fitness_center,
    "Jooga": Icons.self_improvement,
  };

  final IconData defaultCustomIcon = Icons.star;

  // Time
  TimeOfDay startTime = const TimeOfDay(hour: 13, minute: 54);
  late TimeOfDay endTime;
  Duration duration = const Duration(hours: 1);

  @override
  void initState() {
    super.initState();
    endTime = TimeOfDay(
      hour: (startTime.hour + 1) % 24,
      minute: startTime.minute,
    );
    titleController = TextEditingController(text: "Juoksu");
    distanceController = TextEditingController();
    kcalController = TextEditingController();
    _recalculateDuration();
    _loadCustomActivities();
  }

  @override
  void dispose() {
    titleController.dispose();
    distanceController.dispose();
    kcalController.dispose();
    super.dispose();
  }

  // ---------- PERSIST CUSTOM ACTIVITIES ----------

  Future<void> _loadCustomActivities() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      customActivities = prefs.getStringList("custom_activities") ?? [];
    });
  }

  Future<void> _saveCustomActivities() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("custom_activities", customActivities);
  }

  Future<void> _addCustomActivity() async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Lisää oma aktiviteetti",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF233A72),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: "Esim. Tanssi",
                  filled: true,
                  fillColor: const Color(0xFFF3F5FA),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      "Peruuta",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E5AAC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(controller.text.trim());
                    },
                    child: const Text(
                      "Tallenna",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        if (!customActivities.contains(result) &&
            !_defaultActivities.contains(result)) {
          customActivities.add(result);
        }
        activity = result;
        titleController.text = result;
      });
      await _saveCustomActivities();
    }
  }

  // ---------- FORMAT HELPERS ----------

  String _formatDuration(Duration d) {
    final h = d.inHours.toString();
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$h:$m:$s";
  }

  String _formatStartTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return "$h.$m"; // 13.54
  }

  void _recalculateDuration() {
    final startDT = DateTime(2024, 1, 1, startTime.hour, startTime.minute);
    final endDT = DateTime(2024, 1, 1, endTime.hour, endTime.minute);
    final diff = endDT.difference(startDT);
    setState(() {
      duration = diff.isNegative ? Duration.zero : diff;
    });
  }

  // ---------- GENERIC TEXT POPUP (Otsikko / Matka / Kcal) ----------

  Future<void> _editTextField(
    String label,
    TextEditingController controller,
  ) async {
    final temp = TextEditingController(text: controller.text);

    final result = await showDialog<String>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF233A72),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: temp,
                decoration: InputDecoration(
                  hintText: label,
                  filled: true,
                  fillColor: const Color(0xFFF3F5FA),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      // closes only this small popup
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      "Peruuta",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E5AAC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () =>
                        Navigator.of(context).pop(temp.text.trim()),
                    child: const Text(
                      "Tallenna",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() => controller.text = result);
    }
  }

  // ---------- TIME RANGE POPUP (sets start & end, duration auto) ----------

  Future<void> _pickTimeRange() async {
    TimeOfDay tempStart = startTime;
    TimeOfDay tempEnd = endTime;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 80,
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: StatefulBuilder(
            builder: (context, setSB) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 25,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Aseta aika",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF233A72),
                      ),
                    ),
                    const SizedBox(height: 25),
                    _cupertinoTimeRow(
                      label: "Alkaa",
                      time: tempStart,
                      onChanged: (t) => setSB(() => tempStart = t),
                    ),
                    const SizedBox(height: 25),
                    _cupertinoTimeRow(
                      label: "Päättyy",
                      time: tempEnd,
                      onChanged: (t) => setSB(() => tempEnd = t),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            // just close the time popup
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            "Peruuta",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              startTime = tempStart;
                              endTime = tempEnd;

                              final dtStart = DateTime(
                                2024,
                                1,
                                1,
                                startTime.hour,
                                startTime.minute,
                              );
                              final dtEnd = DateTime(
                                2024,
                                1,
                                1,
                                endTime.hour,
                                endTime.minute,
                              );
                              final diff = dtEnd.difference(dtStart);
                              duration = diff.isNegative ? Duration.zero : diff;
                            });

                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E5AAC),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 26,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            "Tallenna",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _cupertinoTimeRow({
    required String label,
    required TimeOfDay time,
    required Function(TimeOfDay) onChanged,
  }) {
    final hours = List<int>.generate(24, (i) => i);
    final minutes = List<int>.generate(60, (i) => i);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF233A72),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 120,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 32,
                  scrollController: FixedExtentScrollController(
                    initialItem: time.hour,
                  ),
                  onSelectedItemChanged: (v) {
                    onChanged(TimeOfDay(hour: v, minute: time.minute));
                  },
                  children: hours
                      .map(
                        (h) => Center(
                          child: Text(
                            h.toString().padLeft(2, '0'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const Text(
                ":",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 32,
                  scrollController: FixedExtentScrollController(
                    initialItem: time.minute,
                  ),
                  onSelectedItemChanged: (v) {
                    onChanged(TimeOfDay(hour: time.hour, minute: v));
                  },
                  children: minutes
                      .map(
                        (m) => Center(
                          child: Text(
                            m.toString().padLeft(2, '0'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------- ACTIVITY SELECT SHEET ----------

  void _selectActivity() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                offset: const Offset(0, 6),
                color: Colors.black.withOpacity(0.12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Valitse aktiviteetti",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF233A72),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...allActivities.map((a) {
                final icon = activityIcons[a] ?? defaultCustomIcon;

                return InkWell(
                  onTap: () {
                    setState(() {
                      activity = a;
                      titleController.text = a;
                    });
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Icon(icon, color: const Color(0xFF2E5AAC)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            a,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                );
              }).toList(),
              const Divider(height: 1, color: Color(0xFFE2E2E2)),
              InkWell(
                onTap: () async {
                  Navigator.pop(context);
                  await _addCustomActivity();
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.add, color: Color(0xFF2E5AAC)),
                      SizedBox(width: 12),
                      Text(
                        "Lisää oma aktiviteetti",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E5AAC),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------- MAIN UI (bottom sheet) ----------

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.92,
      minChildSize: 0.92,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            children: [
              // Top row: X and blue Tallenna button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 26),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E5AAC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      final result = {
                        "type": titleController.text.trim(),
                        "duration": _formatDuration(duration),
                        "distance": distanceController.text.trim(),
                        "kcal": kcalController.text.trim(),
                        "start": _formatStartTime(startTime),
                      };
                      Navigator.pop(context, result);
                    },
                    child: const Text(
                      "Tallenna",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Lisää liikuntasuoritus",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF233A72),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  controller: controller,
                  children: [
                    // Otsikko
                    _sectionHeader("Otsikko"),
                    GestureDetector(
                      onTap: () => _editTextField("Otsikko", titleController),
                      child: _rightValue(titleController.text, editable: true),
                    ),
                    _divider(),

                    // Aktiviteetti
                    _sectionHeader("Aktiviteetti"),
                    GestureDetector(
                      onTap: _selectActivity,
                      child: _rightValue(activity),
                    ),
                    _divider(),

                    // Aloitettu
                    _sectionHeader("Aloitettu"),
                    GestureDetector(
                      onTap: _pickTimeRange,
                      child: _rightValue(_formatStartTime(startTime)),
                    ),
                    const SizedBox(height: 6),

                    // Kesto
                    _sectionHeader("Kesto"),
                    GestureDetector(
                      onTap: _pickTimeRange,
                      child: _rightValue(_formatDuration(duration)),
                    ),
                    _divider(),

                    // Matka
                    _sectionHeader("Matka"),
                    GestureDetector(
                      onTap: () =>
                          _editTextField("Matka (km)", distanceController),
                      child: _rightValue(
                        distanceController.text.isEmpty
                            ? "Lisää km"
                            : "${distanceController.text} km",
                        hintStyle: distanceController.text.isEmpty,
                      ),
                    ),

                    // Kulutettu energia
                    _sectionHeader("Kulutettu energia"),
                    GestureDetector(
                      onTap: () => _editTextField(
                        "Kulutettu energia (kcal)",
                        kcalController,
                      ),
                      child: _rightValue(
                        kcalController.text.isEmpty
                            ? "Lisää kcal"
                            : "${kcalController.text} kcal",
                        hintStyle: kcalController.text.isEmpty,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------- UI helpers ----------

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black54,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _rightValue(
    String text, {
    bool editable = false,
    bool hintStyle = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 1),
        Row(
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: hintStyle ? Colors.grey : const Color(0xFF1A1A1A),
                fontWeight: hintStyle ? FontWeight.w400 : FontWeight.w600,
              ),
            ),
            if (editable) ...[
              const SizedBox(width: 5),
              const Icon(Icons.edit, size: 17, color: Colors.grey),
            ],
          ],
        ),
      ],
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 14),
      child: Divider(color: Color(0xFFE2E2E2)),
    );
  }
}
