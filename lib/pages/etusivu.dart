// ignore_for_file: deprecated_member_use, prefer_const_constructors, unused_import

import 'package:flutter/material.dart';
import 'package:pnksovellus/main.dart';
import 'package:pnksovellus/pages/asetukset.dart';
import 'package:pnksovellus/pages/profile.dart';
import 'package:pnksovellus/pages/chat.dart';
import 'package:pnksovellus/pages/article_page.dart';
import 'omaterveys.dart';
import 'package:pnksovellus/pages/challenge_page.dart';
import 'package:pnksovellus/services/user_data_service.dart';
import 'package:pnksovellus/widgets/app_bottom_nav.dart';

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
  String? userProfile;
  bool loadingProfile = true;
  final UserDataService _dataService = UserDataService();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await _dataService.loadProfileData();
    setState(() {
      userProfile = data.profileType;
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
                          _decorBalls(),
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
                                    fontSize: 22,
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
                                        Color.fromRGBO(72, 150, 195, 1),
                                        Color.fromRGBO(126, 197, 239, 1),
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

                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ShaderMask(
                                        shaderCallback: (bounds) =>
                                            const LinearGradient(
                                          colors: [
                                            Color.fromRGBO(13, 59, 118, 1),
                                            Color.fromRGBO(97, 150, 239, 1),
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ).createShader(bounds),
                                        child: const Text(
                                          "Aiheet",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      TextButton(
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
                                            fontWeight: FontWeight.w500,
                                            decoration: TextDecoration.underline,
                                            decorationColor: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Divider(
                                  thickness: 0.8,
                                  height: 1,
                                  color: Colors.grey.withOpacity(0.3), // subtle like in your pic
                                ),

                                const SizedBox(height: 12),


                                const SizedBox(height: 12),

                                SizedBox(
                                    height: 150, // enough to fit your bigger chips
                                    child: ListView(
                                      scrollDirection: Axis.horizontal,
                                      padding: const EdgeInsets.only(left: 8),
                                      children: const [
                                        CategoryChip(
                                          icon: Icons.bedtime,
                                          label: 'Uni',
                                          gradientColors: [Color(0xFF74B9FF), Color(0xFF6CA7FF)],
                                          iconGradient: [Color(0xFF5FA8FF), Color(0xFF2F7CFF)],
                                        ),
                                        SizedBox(width: 16),

                                        CategoryChip(
                                          icon: Icons.restaurant_menu,
                                          label: 'Ravinto',
                                          gradientColors: [Color(0xFFC39BFF), Color(0xFFB28CFF)],
                                          iconGradient: [Color(0xFFB785FF), Color(0xFF9F60FF)],
                                        ),
                                        SizedBox(width: 16),

                                        CategoryChip(
                                          icon: Icons.favorite,
                                          label: 'Sydän',
                                          gradientColors: [Color(0xFF7DEFA5), Color(0xFF57DB80)],
                                          iconGradient: [Color(0xFF63E690), Color(0xFF34C967)],
                                        ),
                                        SizedBox(width: 16),

                                        CategoryChip(
                                          icon: Icons.bolt,
                                          label: 'Energia',
                                          gradientColors: [Color(0xFF8EF0E6), Color(0xFF63D8CF)],
                                          iconGradient: [Color(0xFF6AEFE0), Color(0xFF30CABA)],
                                        ),
                                        SizedBox(width: 16),
                                      ],
                                    ),
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
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }

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
                requiredSteps: 14,
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
                requiredSteps: 5,
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
        constraints: const BoxConstraints(minHeight: 150),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top color band
            Container(
              height: 70,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFC5D3FA),
                    Color(0xFFDFECFF),
                  ],
                ),
              ),
            ),

            // Text area
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Color(0xFF3C4A62),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF5D6A7C),
                      height: 1.25,
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

}

class CategoryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradientColors;
  final List<Color> iconGradient;

  const CategoryChip({
    super.key,
    required this.icon,
    required this.label,
    required this.gradientColors,
    required this.iconGradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,     // bigger width
      height: 130,    // bigger height
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ICON
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: iconGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Icon(
                icon,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // TEXT INSIDE THE BOX
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
