// ignore_for_file: unused_local_variable, deprecated_member_use, prefer_const_constructors, prefer_const_declarations

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pnksovellus/pages/etusivu.dart';
import 'package:pnksovellus/pages/chat.dart';
import 'package:pnksovellus/pages/profile.dart';
import 'package:pnksovellus/pages/asetukset.dart';

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

class TrackerPage extends StatefulWidget {
  const TrackerPage({super.key});

  @override
  State<TrackerPage> createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> {
  int waterGlasses = 5;
  int steps = 3460;

  int selectedMood = 2;
  Map<int, int> moodMap = {};

  int _currentIndex = 1;

  late DateTime currentMonth;

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

  String _monthKey(DateTime date) => "moods_${date.year}_${date.month}";

  Future<void> _loadMoodData() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_monthKey(currentMonth));

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
  }

  Future<void> _saveMoodData() async {
    final prefs = await SharedPreferences.getInstance();
    final enc = moodMap.entries.map((e) => "${e.key}:${e.value}").join(",");
    prefs.setString(_monthKey(currentMonth), enc);
  }

  void _prevMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month - 1, 1);
    });
    _loadMoodData();
  }

  void _nextMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
    });
    _loadMoodData();
  }

  void _navigate(int index) {
    if (index == _currentIndex) return;

    setState(() => _currentIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Etusivu()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TrackerPage()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ChatPage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfilePage()),
        );
        break;
    }
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
                      _buildCalendarCard(),
                      SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.only(top: 320),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              _buildExerciseCard(),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            _decorBalls(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
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
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Hei, miten tänään liikutaan?",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF233A72),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _buildWaterAndMoods(today),
        const SizedBox(height: 15),
        _buildStepArc(),
        const SizedBox(height: 15),
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
              IconButton(
                onPressed: () {
                  setState(() {
                    if (waterGlasses > 0) waterGlasses--;
                  });
                },
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  "$waterGlasses",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => waterGlasses++),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          Row(
            children: List.generate(3, (i) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedMood = i;
                    moodMap[today.day] = i;
                  });
                  _saveMoodData();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: selectedMood == i
                        ? Colors.white
                        : Colors.transparent,
                    child: Image.asset(moodIcons[i], width: 32, height: 32),
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
    return CustomPaint(
      painter: StepArcPainter(steps: steps),
      child: SizedBox(
        height: 160,
        width: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "$steps",
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
            const SizedBox(height: 20),
          ],
        ),
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
                child: const Icon(Icons.arrow_back_ios, size: 16),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    DateFormat("LLLL yyyy", "fi_FI").format(currentMonth),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF233A72),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: _nextMonth,
                child: const Icon(Icons.arrow_forward_ios, size: 16),
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
              bool isToday =
                  today.year == currentMonth.year &&
                  today.month == currentMonth.month &&
                  today.day == day;

              Color moodColor = Colors.transparent;

              if (moodMap.containsKey(day)) {
                switch (moodMap[day]) {
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

              return GestureDetector(
                onTap: () {
                  setState(() => moodMap[day] = selectedMood);
                  _saveMoodData();
                },
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isToday ? const Color(0xFFCCE0FF) : moodColor,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Center(
                    child: Text(
                      "$day",
                      style: TextStyle(
                        fontWeight: isToday
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isToday
                            ? const Color(0xFF0B3D91)
                            : Colors.black87,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ========================= EXERCISES =========================

  Widget _buildExerciseCard() {
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
          const Text(
            "5 liikunta suoritusta",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF233A72),
            ),
          ),
          const SizedBox(height: 14),
          _buildExerciseItem(
            Icons.directions_run,
            "Juoksu",
            "35 min",
            "7.12 km",
          ),
          _buildExerciseItem(Icons.pedal_bike, "Pyöräily", "24 min", "4.22 km"),
          const SizedBox(height: 18),
          Center(
            child: Column(
              children: const [
                Text(
                  "näe kaikki",
                  style: TextStyle(
                    color: Color(0xFF2E5AAC),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, color: Color(0xFF2E5AAC)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
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
              child: const Icon(Icons.add, size: 34, color: Color(0xFF2E5AAC)),
            ),
          ),
        ],
      ),
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

  // ========================= BOTTOM NAV =========================

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(Icons.home, 'Etusivu', 0),
          _buildNavItem(Icons.bar_chart_rounded, 'OmaTerveys', 1),
          _buildNavItem(Icons.chat_bubble_outline, 'Chatti', 2),
          _buildNavItem(Icons.person_outline, 'Profiili', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _navigate(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.blueGrey,
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
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
