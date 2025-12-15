// ignore_for_file: deprecated_member_use, prefer_const_constructors, unused_import

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pnksovellus/main.dart';
import 'package:pnksovellus/pages/asetukset.dart';
import 'package:pnksovellus/pages/chat.dart';
import 'package:pnksovellus/pages/article_page.dart';
import 'package:pnksovellus/pages/profile.dart';
import 'omaterveys.dart';
import 'package:pnksovellus/pages/challenge_page.dart';
import 'package:pnksovellus/services/user_data_service.dart';
import 'package:pnksovellus/widgets/app_bottom_nav.dart';
import 'package:pnksovellus/services/event_service.dart';
import 'package:pnksovellus/services/ajankohtaista_service.dart';
import 'package:pnksovellus/pages/ajankohtaista_detail.dart';
import 'package:pnksovellus/pages/article_service.dart';
import 'package:pnksovellus/pages/article_model.dart';
import 'package:pnksovellus/pages/article_view.dart';
import 'package:pnksovellus/services/achievement_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  bool loadingArticles = false;
  bool loadingAchievements = false;
  final UserDataService _dataService = UserDataService();
  final PageController _articleController =
      PageController(viewportFraction: 0.9);
  final EventService _eventService = EventService();
  final AjankohtaistaService _ajankohtaistaService = AjankohtaistaService();
  final ArticleService _articleService = ArticleService();
  final AchievementService _achievementService = AchievementService();
  final TextEditingController _searchController = TextEditingController();
  List<AjankohtaistaItem> _ajankohtaista = [];
  List<Article> _allArticles = [];
  List<Article> _searchResults = [];
  Map<String, String> _achievements = {};
  int _currentArticleIndex = 0;
  Timer? _articleTimer;
  Timer? _searchDebounce;

  int get _pageCount {
    // 1 for events + N ajankohtaista items
    return 1 + _ajankohtaista.length;
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadArticles();
    _loadAchievements();
    _startArticleAutoScroll();
  }

  @override
  void dispose() {
    _articleTimer?.cancel();
    _searchDebounce?.cancel();
    _articleController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await _dataService.loadProfileData();
      if (mounted) {
        setState(() {
          userProfile = data.profileType;
          loadingProfile = false;
        });
      }
    } catch (_) {
      // Even if loading fails, show the page so the user isn't stuck on a blank screen.
      if (mounted) {
        setState(() => loadingProfile = false);
      }
    }
  }

  Future<void> _loadArticles() async {
    if (mounted) {
      setState(() => loadingArticles = true);
    }
    try {
      final articles = await _articleService.getArticles();
      if (mounted) {
        setState(() {
          _allArticles = articles;
          loadingArticles = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => loadingArticles = false);
      }
    }
  }

  Future<void> _loadAchievements() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() => _achievements = {});
      }
      return;
    }
    if (mounted) {
      setState(() => loadingAchievements = true);
    }
    try {
      final map = await _achievementService.loadAchievements();
      if (mounted) {
        setState(() {
          _achievements = map;
          loadingAchievements = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => loadingAchievements = false);
      }
    }
  }

  void _startArticleAutoScroll() {
    _articleTimer?.cancel();
    _articleTimer = Timer.periodic(const Duration(seconds: 7), (_) {
      if (!mounted) return;
      final count = _pageCount;
      if (count == 0) return;
      final nextPage = (_currentArticleIndex + 1) % count;
      _articleController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      _currentArticleIndex = nextPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF4FF),
      body: loadingProfile
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragEnd: _handleHorizontalSwipe,
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final overlayWidth = constraints.maxWidth - 32;
                    return SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 480,
                              left: -300,
                              child: Container(
                                width: 1000,
                                height: 1000,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromRGBO(46, 90, 172, 0.15),
                                      blurRadius: 80,
                                      spreadRadius: 30,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 16, 16, 90),
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

                                  // Search bar + overlayed results (leader before follower)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      TextField(
                                        controller: _searchController,
                                        onChanged: _onSearchChanged,
                                        decoration: InputDecoration(
                                          hintText: 'Hae artikkeleja',
                                          prefixIcon: const Icon(Icons.search),
                                          suffixIcon: _searchController
                                                  .text.isNotEmpty
                                              ? IconButton(
                                                  icon: const Icon(Icons.close),
                                                  onPressed: () {
                                                    _searchController.clear();
                                                    _onSearchChanged('');
                                                  },
                                                )
                                              : null,
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                      ),
                                      if (_searchResults.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          width: overlayWidth,
                                          child: Material(
                                            elevation: 8,
                                            color: Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            child: _buildSearchResults(),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),

                                  const SizedBox(height: 20),

                                  if (loadingArticles)
                                    const Padding(
                                      padding: EdgeInsets.only(top: 8.0),
                                      child: LinearProgressIndicator(
                                        minHeight: 3,
                                        color: Color(0xFF2E5AAC),
                                        backgroundColor:
                                            Color.fromRGBO(46, 90, 172, 0.15),
                                      ),
                                    ),

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

                                  // Events + Ajankohtaista PageView
                                  SizedBox(
                                    height: 255,
                                    child:
                                        StreamBuilder<List<AjankohtaistaItem>>(
                                      stream: _ajankohtaistaService.latest(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          _ajankohtaista = snapshot.data!;
                                        }
                                        return Column(
                                          children: [
                                            Expanded(
                                              child: PageView.builder(
                                                controller: _articleController,
                                                itemCount: _pageCount,
                                                onPageChanged: (index) {
                                                  setState(() {
                                                    _currentArticleIndex =
                                                        index;
                                                  });
                                                },
                                                itemBuilder: (context, index) {
                                                  if (index == 0) {
                                                    return _buildEventsSlide();
                                                  }
                                                  final item =
                                                      _ajankohtaista[index - 1];
                                                  return _buildAjankohtaistaCard(
                                                    item,
                                                  );
                                                },
                                              ),
                                            ),
                                            if (_pageCount > 1)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 8,
                                                ),
                                                child: _buildDots(),
                                              ),
                                          ],
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
                                          Color.fromRGBO(72, 150, 195, 1),
                                          Color.fromRGBO(126, 197, 239, 1),
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ).createShader(bounds),
                                      child: const Text(
                                        'Saavutukset',
                                        style: TextStyle(
                                          fontSize: 18,
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
                                    children: _buildAchievementsRow(),
                                  ),

                                  const SizedBox(height: 30),

                                  // Challenges title
                                  ShaderMask(
                                    shaderCallback: (bounds) =>
                                        const LinearGradient(
                                      colors: [
                                        Color.fromRGBO(67, 117, 184, 1),
                                        Color.fromRGBO(97, 133, 197, 1),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ).createShader(bounds),
                                    child: const Text(
                                      'Sinulle suositellut haasteet',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
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
                                              Color.fromRGBO(67, 117, 184, 1),
                                              Color.fromRGBO(97, 133, 197, 1),
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
                                              decoration:
                                                  TextDecoration.underline,
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
                                    color: Colors.grey.withOpacity(
                                        0.3), // subtle like in your pic
                                  ),

                                  const SizedBox(height: 12),

                                  const SizedBox(height: 12),

                                  SizedBox(
                                    height:
                                        150, // enough to fit your bigger chips
                                    child: ListView(
                                      scrollDirection: Axis.horizontal,
                                      padding: const EdgeInsets.only(left: 8),
                                      children: const [
                                        CategoryChip(
                                          icon: Icons.bedtime,
                                          label: 'Uni',
                                          gradientColors: [
                                            Color(0xFF74B9FF),
                                            Color(0xFF6CA7FF)
                                          ],
                                          iconGradient: [
                                            Color(0xFF5FA8FF),
                                            Color(0xFF2F7CFF)
                                          ],
                                        ),
                                        SizedBox(width: 16),
                                        CategoryChip(
                                          icon: Icons.restaurant_menu,
                                          label: 'Ravinto',
                                          gradientColors: [
                                            Color(0xFFC39BFF),
                                            Color(0xFFB28CFF)
                                          ],
                                          iconGradient: [
                                            Color(0xFFB785FF),
                                            Color(0xFF9F60FF)
                                          ],
                                        ),
                                        SizedBox(width: 16),
                                        CategoryChip(
                                          icon: Icons.favorite,
                                          label: 'Sydän',
                                          gradientColors: [
                                            Color(0xFF7DEFA5),
                                            Color(0xFF57DB80)
                                          ],
                                          iconGradient: [
                                            Color(0xFF63E690),
                                            Color(0xFF34C967)
                                          ],
                                        ),
                                        SizedBox(width: 16),
                                        CategoryChip(
                                          icon: Icons.bolt,
                                          label: 'Energia',
                                          gradientColors: [
                                            Color(0xFF8EF0E6),
                                            Color(0xFF63D8CF)
                                          ],
                                          iconGradient: [
                                            Color(0xFF6AEFE0),
                                            Color(0xFF30CABA)
                                          ],
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
            ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
      return IconButton(
        icon: const Icon(Icons.settings,
            color: Color.fromARGB(255, 71, 147, 210), size: 25),
        tooltip: 'Asetukset',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AsetuksetPage()),
          );
        },
      );
    } else if (icon == Icons.notifications) {
      final notifications = <Map<String, String>>[
        {"title": "Uusi haaste", "body": "Kokeile uutta kävelyhaastetta!"},
        {"title": "Muistutus", "body": "Juomapulssi tänään vielä tekemättä."},
        {"title": "Artikkeli", "body": "Lue: 5 tapaa parantaa yöuniasi."},
      ];

      return PopupMenuButton<int>(
        icon: const Icon(Icons.notifications,
            color: Color.fromARGB(255, 71, 147, 210), size: 25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        offset: const Offset(0, 40),
        itemBuilder: (context) => [
          for (var n in notifications)
            PopupMenuItem(
              enabled: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    n["title"] ?? "",
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF485885),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    n["body"] ?? "",
                    style: const TextStyle(color: Colors.black87, fontSize: 12),
                  ),
                ],
              ),
            ),
        ],
      );
    } else {
      return IconButton(
        icon: Icon(icon, color: Colors.blue, size: 25),
        tooltip: tooltip,
        onPressed: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('$tooltip avattu')));
        },
      );
    }
  }

  Widget _buildEventsSlide() {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Tapahtumakalenteri',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Icon(Icons.calendar_today, size: 18, color: Colors.blue),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: StreamBuilder<List<EventItem>>(
                    stream: _eventService.upcomingEvents(limit: 5),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      }
                      final events = snapshot.data ?? [];
                      if (events.isEmpty) {
                        return const Center(
                          child: Text(
                            'Ei tulevia tapahtumia juuri nyt.\nLisää ne Firebasen events-kokoelmaan.',
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: events.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 12,
                          color: Colors.grey.withOpacity(0.25),
                        ),
                        itemBuilder: (context, i) {
                          final e = events[i];
                          final date =
                              '${e.date.day.toString().padLeft(2, '0')}.${e.date.month.toString().padLeft(2, '0')}.${e.date.year}';
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromRGBO(46, 90, 172, 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    '${e.date.day}\n${_monthShortFi(e.date)}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      color: Color(0xFF2E5AAC),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      date,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    if (e.location != null &&
                                        e.location!.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          const Icon(Icons.place,
                                              size: 14, color: Colors.blue),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              e.location!,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    if (e.description != null &&
                                        e.description!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        e.description!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF5D6A7C),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAjankohtaistaCard(AjankohtaistaItem item) {
    final date =
        '${item.date.day.toString().padLeft(2, '0')}.${item.date.month.toString().padLeft(2, '0')}.${item.date.year}';
    final preview = (() {
      final raw = (item.body ?? '').replaceAll('\n', ' ').trim();
      if (raw.length <= 60) return raw;
      return '${raw.substring(0, 60)}…';
    })();
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AjankohtaistaDetailPage(item: item),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      image: item.imageUrl != null && item.imageUrl!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(item.imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: (item.imageUrl == null || item.imageUrl!.isEmpty)
                        ? const Center(
                            child: Icon(Icons.image, color: Colors.grey),
                          )
                        : null,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            date,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          if (preview.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              preview,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF5D6A7C),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _monthShortFi(DateTime date) {
    const months = [
      'tam',
      'hel',
      'maa',
      'huh',
      'tou',
      'kes',
      'hei',
      'elo',
      'syy',
      'lok',
      'mar',
      'jou'
    ];
    return months[date.month - 1];
  }

  List<Widget> _buildAchievementsRow() {
    if (loadingAchievements) {
      return const [
        SizedBox(
          height: 40,
          width: 40,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        SizedBox(width: 10),
        SizedBox(
          height: 40,
          width: 40,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        SizedBox(width: 10),
        SizedBox(
          height: 40,
          width: 40,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ];
    }

    final entries = _achievements.entries.take(3).toList();
    if (entries.isEmpty) {
      return const [
        Icon(Icons.emoji_events_outlined, color: Colors.grey, size: 40),
        Icon(Icons.emoji_events_outlined, color: Colors.grey, size: 40),
        Icon(Icons.emoji_events_outlined, color: Colors.grey, size: 40),
      ];
    }

    return entries
        .map(
          (e) => Column(
            children: [
              const Icon(Icons.emoji_events,
                  color: Color(0xFF2E5AAC), size: 40),
              const SizedBox(height: 4),
              SizedBox(
                width: 90,
                child: Text(
                  e.value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF485885),
                  ),
                ),
              ),
            ],
          ),
        )
        .toList();
  }

  Widget _buildDots() {
    final dots = List.generate(_pageCount, (i) {
      final isActive = i == _currentArticleIndex;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1C2D50) : const Color(0xFF9EABC2),
          shape: BoxShape.circle,
        ),
      );
    });

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: dots,
      ),
    );
  }

  void _handleHorizontalSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    const threshold = 400;
    if (velocity < -threshold) {
      // Swipe left → Omaterveys
      _navigateTo(const TrackerPage());
    }
  }

  void _navigateTo(Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      try {
        // Keep search light so typing stays responsive.
        final lower = query.toLowerCase();
        if (_allArticles.isEmpty) {
          setState(() => _searchResults = []);
          return;
        }
        String safeLower(String? v) => (v ?? "").toLowerCase();
        final matches = _allArticles.where((a) {
          final title = safeLower(a.title);
          final category = safeLower(a.category);
          // Check content only lightly (avoid huge strings causing lag)
          final contentSnippet = safeLower(
            a.content.length > 400 ? a.content.substring(0, 400) : a.content,
          );
          return title.contains(lower) ||
              category.contains(lower) ||
              contentSnippet.contains(lower);
        }).toList();
        // Sort so title hits first
        matches.sort((a, b) {
          final aTitleHit = a.title.toLowerCase().contains(lower) ? 1 : 0;
          final bTitleHit = b.title.toLowerCase().contains(lower) ? 1 : 0;
          if (aTitleHit != bTitleHit) return bTitleHit - aTitleHit;
          return a.title.compareTo(b.title);
        });
        setState(() => _searchResults = matches.take(5).toList());
      } catch (_) {
        // If malformed article data slips through, fail silently instead of crashing.
        if (mounted) setState(() => _searchResults = []);
      }
    });
  }

  Widget _buildSearchResults() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _searchResults.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: Colors.grey.withOpacity(0.2),
        ),
        itemBuilder: (context, i) {
          final art = _searchResults[i];
          return ListTile(
            leading:
                const Icon(Icons.article_outlined, color: Color(0xFF2E5AAC)),
            title: Text(
              art.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              art.date.isNotEmpty ? art.date : art.category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ArticleViewPage(article: art),
                ),
              );
            },
          );
        },
      ),
    );
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
      width: 130, // bigger width
      height: 130, // bigger height
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
