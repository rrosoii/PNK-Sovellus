// ignore_for_file: deprecated_member_use, prefer_const_constructors, unused_import

import 'package:flutter/material.dart';
import 'package:pnksovellus/main.dart';
import 'package:pnksovellus/pages/asetukset.dart';
import 'package:pnksovellus/pages/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pnksovellus/pages/article_page.dart';
import 'omaterveys.dart';
import 'package:pnksovellus/pages/challenge_page.dart';

class ArticlesListPage extends StatelessWidget {
  const ArticlesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kaikki artikkelit')),
      body: const Center(child: Text('Articles list')),
    );
  }
}

class Etusivu extends StatefulWidget {
  const Etusivu({super.key});

  @override
  State<Etusivu> createState() => _EtusivuState();
}

class _EtusivuState extends State<Etusivu> {
  int _selectedIndex = 0;

  String? userProfile;
  bool loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userProfile = prefs.getString('userProfile');
      loadingProfile = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF4FF),
      body: loadingProfile
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 400,
                            left: -300,
                            child: Container(
                              width: 1000,
                              height: 1000,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Notifications & Settings
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildIconButton(
                                        Icons.notifications,
                                        'Ilmoitukset',
                                      ),
                                      const SizedBox(width: 8),
                                      _buildIconButton(
                                        Icons.settings,
                                        'Asetukset',
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Search bar
                                TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Hae artikkeleja',
                                    prefixIcon: const Icon(Icons.search),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Welcome text
                                const Text(
                                  'Tervetuloa takaisin!',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(72, 88, 133, 1),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Article PageView
                                SizedBox(
                                  height: 180,
                                  child: PageView.builder(
                                    controller: PageController(
                                      viewportFraction: 0.9,
                                    ),
                                    itemCount: 3,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8,
                                        ),
                                        child: Material(
                                          elevation: 8,
                                          shadowColor: Colors.black.withOpacity(
                                            0.25,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            child: Container(
                                              color: Colors.white,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Image.asset(
                                                    '',
                                                    height: 100,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  const Padding(
                                                    padding: EdgeInsets.all(
                                                      8.0,
                                                    ),
                                                    child: Text(
                                                      'Influenssarokote tehokkain suoja influenssaa ja sen jälkitauteja vastaan',
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                  const Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 8.0,
                                                    ),
                                                    child: Text(
                                                      '20.10.2025',
                                                      style: TextStyle(
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                const SizedBox(height: 50),

                                // Achievements
                                Center(
                                  child: ShaderMask(
                                    shaderCallback: (bounds) =>
                                        const LinearGradient(
                                      colors: [
                                        Color(0xFF485885),
                                        Color(0xFF2196F3),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ).createShader(bounds),
                                    child: const Text(
                                      'Saavutukset',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: const [
                                    Icon(
                                      Icons.local_fire_department,
                                      color: Colors.deepOrange,
                                      size: 40,
                                    ),
                                    Icon(
                                      Icons.bolt,
                                      color: Colors.green,
                                      size: 40,
                                    ),
                                    Icon(
                                      Icons.water_drop,
                                      color: Colors.blue,
                                      size: 40,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 30),

                                // Challenges title
                                const Text(
                                  'Sinulle suositellut haasteet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                Row(
                                  children: _recommendedChallengesFor(
                                    userProfile,
                                  ),
                                ),

                                const SizedBox(height: 40),

                                // ---------------------------
                                // ARTIKKELIT (fixed section)
                                // ---------------------------
                                Center(
                                  child: ShaderMask(
                                    shaderCallback: (bounds) =>
                                        const LinearGradient(
                                      colors: [
                                        Color(0xFF485885),
                                        Color(0xFF2196F3),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ).createShader(bounds),
                                    child: const Text(
                                      "Artikkelit",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ArticleListPage(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "Kaikki artikkelit",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Text(
                                    "Aiheet",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF485885),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: const [
                                    CategoryChip(
                                      icon: Icons.bedtime,
                                      label: 'Uni',
                                    ),
                                    CategoryChip(
                                      icon: Icons.restaurant_menu,
                                      label: 'Ravinto',
                                    ),
                                    CategoryChip(
                                      icon: Icons.favorite,
                                      label: 'Sydän',
                                    ),
                                    CategoryChip(
                                      icon: Icons.bolt,
                                      label: 'Energia',
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 50),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      bottomNavigationBar: Container(
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
      ),
    );
  }

  // ---------------- HELPERS ----------------

  Widget _buildIconButton(IconData icon, String tooltip) {
    if (icon == Icons.settings) {
      return PopupMenuButton<int>(
        icon: const Icon(Icons.settings, color: Colors.blue, size: 25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        offset: const Offset(0, 40),
        onSelected: (value) {
          if (value == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AsetuksetPage()),
            );
          }
          if (value == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_outline,
                  color: Color.fromARGB(255, 72, 78, 133),
                ),
                SizedBox(width: 10),
                Text(
                  "Profiili",
                  style: TextStyle(color: Color.fromARGB(255, 72, 78, 133)),
                ),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.settings_outlined,
                  color: Color.fromARGB(255, 72, 78, 133),
                ),
                SizedBox(width: 10),
                Text(
                  "Asetukset",
                  style: TextStyle(color: Color.fromARGB(255, 72, 78, 133)),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return Stack(
        children: [
          IconButton(
            icon: Icon(icon, color: Colors.blue, size: 25),
            tooltip: tooltip,
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('$tooltip avattu')));
            },
          ),
          if (icon == Icons.notifications)
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
      );
    }
  }

  Widget _buildChallengeCard(String title, String desc) {
    return GestureDetector(
      onTap: () {
        String normalized = title.toLowerCase();

        if (normalized.contains("kävely")) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChallengePage(
                challengeId: "steps_10000_week",
                title: "Kävelyhaaste",
                description: "Kävele 10 000 askelta joka päivä viikon ajan.",
                type: "steps",
                durationDays: 7,
                requiredSteps: 10000,
              ),
            ),
          );
        } else if (normalized.contains("liiku jokapäiv")) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChallengePage(
                challengeId: "exercise_daily_14",
                title: "Liiku jokapäivä",
                description: "Tee liikuntasuoritus joka päivä 2 viikon ajan.",
                type: "exercise",
                durationDays: 14,
              ),
            ),
          );
        } else if (normalized.contains("liiku aktiivis")) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChallengePage(
                challengeId: "exercise_weekly_5",
                title: "Liiku aktiivisesti",
                description: "Tee viisi (5) liikuntasuoritusta viikossa.",
                type: "exerciseWeekly",
                durationDays: 7,
              ),
            ),
          );
        } else if (normalized.contains("100 000")) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChallengePage(
                challengeId: "steps_100k_month",
                title: "100 000 askelta",
                description: "Kerää 100 000 askelta kuukauden aikana.",
                type: "stepsAccumulated",
                durationDays: 30,
                requiredSteps: 100000,
              ),
            ),
          );
        }
      },
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(desc),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _recommendedChallengesFor(String? profile) {
    if (profile == 'Koala') {
      return [
        Expanded(
          child: _buildChallengeCard(
            'Kävelyhaaste',
            'Kävele 5 000 askelta päivässä viikon ajan',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildChallengeCard(
            'Juomahaaste',
            'Juo 8 lasillista vettä päivittäin',
          ),
        ),
      ];
    }

    if (profile == 'Delfiini') {
      return [
        Expanded(
          child: _buildChallengeCard(
            'Kävelyhaaste',
            'Kävele 10 000 askelta päivässä viikon ajan',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildChallengeCard(
            'Liiku aktiivisesti',
            'Tee viisi (5) liikuntasuoritusta viikossa',
          ),
        ),
      ];
    }

    if (profile == 'Susi') {
      return [
        Expanded(
          child: _buildChallengeCard(
            'Liiku jokapäivä',
            'Tee liikuntasuoritus joka päivä 2 viikon ajan',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildChallengeCard(
            '100 000 askelta',
            'Kerää 100 000 askelta kuukauden aikana',
          ),
        ),
      ];
    }

    return [
      Expanded(
        child: _buildChallengeCard(
          'Aloita hyvinvointisi',
          'Kokeile mitä tahansa haasteita!',
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _buildChallengeCard(
          'Tervetuloa!',
          'Valitse mikä tuntuu hyvältä',
        ),
      ),
    ];
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);

        if (index == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const Etusivu()),
          );
        }

        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TrackerPage()),
          );
        }
      },
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

class CategoryChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const CategoryChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.white,
          child: Icon(icon, color: Colors.blue, size: 26),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: Color(0xFF485885),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
