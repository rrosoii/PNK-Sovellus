// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pnksovellus/routes/route_observer.dart';
import 'package:pnksovellus/services/user_data_service.dart';
import 'package:pnksovellus/pages/kysely.dart';
import 'package:pnksovellus/widgets/app_bottom_nav.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with RouteAware {
  String username = "";
  String email = "example@email.com"; // temporary
  String profileType = "";
  File? avatarImage;
  String? joinDate;

  List<Map<String, dynamic>> activeChallenges = [];
  List<Map<String, dynamic>> completedChallenges = [];
  bool loadingChallenges = true;
  final Map<String, Map<String, dynamic>> _challengeMeta = {
    "steps_10000_week": {
      "title": "K\u00e4velyhaaste",
      "icon": Icons.directions_walk,
      "durationDays": 7
    },
    "exercise_daily_14": {
      "title": "Liiku jokap\u00e4iv\u00e4",
      "icon": Icons.fitness_center,
      "durationDays": 14
    },
    "exercise_weekly_5": {
      "title": "Liiku aktiivisesti",
      "icon": Icons.run_circle_outlined,
      "durationDays": 7
    },
    "steps_100k_month": {
      "title": "100 000 askelta",
      "icon": Icons.flag,
      "durationDays": 30
    },
  };

  bool editingName = false;
  final _nameController = TextEditingController();
  final UserDataService _dataService = UserDataService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _ensureJoinDate();
    _loadChallengeProgress();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Refresh data if returning from a page that might update profile info
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Refresh data if returning from a page that might update profile info
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final data = await _dataService.loadProfileData();

    username = data.username;
    profileType = data.profileType;

    if (data.avatarPath != null && File(data.avatarPath!).existsSync()) {
      avatarImage = File(data.avatarPath!);
    } else {
      avatarImage = null;
    }

    _nameController.text = username;

    setState(() {});
  }

  Future<void> _saveName(String newName) async {
    await _dataService.saveProfileName(newName);
  }

  Future<void> _ensureJoinDate() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString("join_date");
    if (saved != null && saved.isNotEmpty) {
      setState(() => joinDate = saved);
      return;
    }

    final today = _formatDate(DateTime.now());
    await prefs.setString("join_date", today);
    setState(() => joinDate = today);
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
    );

    if (pickedFile != null) {
      avatarImage = File(pickedFile.path);

      await _dataService.saveAvatarPath(pickedFile.path);

      setState(() {});
    }
  }

  Future<void> _loadChallengeProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        loadingChallenges = false;
        activeChallenges = [];
        completedChallenges = [];
      });
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      final data = doc.data() ?? {};
      final Map<String, dynamic> challenges =
          (data["activeChallenges"] ?? {}) as Map<String, dynamic>;

      final List<Map<String, dynamic>> active = [];
      final List<Map<String, dynamic>> completed = [];

      challenges.forEach((id, value) {
        if (value is! Map<String, dynamic>) return;
        final bool isActive = value["isActive"] == true;
        final int currentDay = (value["currentDay"] ?? 0) as int;
        final int totalDays = (value["durationDays"] ??
            _challengeMeta[id]?["durationDays"] ??
            1) as int;
        final double progress =
            totalDays > 0 ? (currentDay / totalDays).clamp(0.0, 1.0) : 0.0;
        final meta = _challengeMeta[id];
        final String title = meta?["title"] as String? ?? id;
        final IconData icon = meta?["icon"] as IconData? ?? Icons.emoji_events;
        final entry = {
          "id": id,
          "title": title,
          "icon": icon,
          "progress": progress,
        };

        if (isActive) {
          active.add(entry);
        } else if (currentDay >= totalDays) {
          completed.add(entry);
        }
      });

      setState(() {
        activeChallenges = active;
        completedChallenges = completed;
        loadingChallenges = false;
      });
    } catch (_) {
      setState(() {
        loadingChallenges = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7F0FF),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTopHeader(),
              const SizedBox(height: 10),
              _buildInfoRow(),
              const SizedBox(height: 20),
              _buildTitle("Saavutukset"),
              const SizedBox(height: 10),
              _buildAchievementsCard(),
              const SizedBox(height: 25),
              _buildTitle("Kyselyt"),
              const SizedBox(height: 10),
              _buildSurveyCard(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------
  // TOP CURVED HEADER WITH INLINE EDITING + CAMERA BUTTON
  // --------------------------------------------------------
  Widget _buildTopHeader() {
    return Stack(
      children: [
        ClipPath(
          clipper: _CurvedHeaderClipper(),
          child: Container(
            height: 300,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1F3C88), Color(0xFF0A2E68)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),

        // Back + Title
        // Back button + title
        Positioned(
          top: 16,
          left: 16,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Row(
              children: const [
                Icon(Icons.arrow_back_ios, color: Colors.white, size: 22),
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
        ),

        // Avatar + Username + Edit Inline
        Positioned.fill(
          top: 85,
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 52,
                      backgroundColor: Colors.white,
                      backgroundImage: avatarImage != null
                          ? FileImage(avatarImage!)
                          : const AssetImage("assets/avatar.png")
                              as ImageProvider,
                    ),
                  ),

                  // CAMERA ICON overlay
                  GestureDetector(
                    onTap: _pickAvatar,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 4, right: 4),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Inline username editing
              editingName ? _buildNameEditor() : _buildNameDisplay(),

              const SizedBox(height: 6),

              // Profile Type
            ],
          ),
        ),
      ],
    );
  }

  // Shows name + pencil icon
  Widget _buildNameDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          username,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () {
            setState(() => editingName = true);
          },
          child: const Icon(Icons.edit, color: Colors.white, size: 18),
        ),
      ],
    );
  }

  // Name editing field
  Widget _buildNameEditor() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 180,
          child: TextField(
            controller: _nameController,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white70),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () {
            username = _nameController.text.trim();
            _saveName(username);
            editingName = false;
            setState(() {});
          },
          child: const Icon(Icons.check, color: Colors.white, size: 20),
        ),
      ],
    );
  }

  // --------------------------------------------------------
  // BOTTOM SECTION (unchanged from earlier)
  // --------------------------------------------------------

  Widget _buildInfoRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _infoCard("Liittymispäivä", joinDate ?? "—"),
        _infoCard("Hyvinvointiprofiili", profileType),
      ],
    );
  }

  Widget _infoCard(String title, String value) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
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
              color: Colors.blue.shade800,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(String t) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Text(
        t,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Colors.blue.shade900,
        ),
      ),
    );
  }

  Widget _buildAchievementsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (loadingChallenges)
            const Center(child: CircularProgressIndicator())
          else ...[
            Row(
              children: [
                const Text(
                  "Aktiiviset haasteet",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Text(
                  "Päivittyy automaattisesti",
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (activeChallenges.isEmpty)
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Ei aktiivisia haasteita juuri nyt.",
                  style: TextStyle(color: Colors.black54),
                ),
              )
            else
              ...activeChallenges
                  .map(
                    (c) => _progressRow(
                      c["icon"] as IconData? ?? Icons.flag,
                      c["title"] as String? ?? "",
                      (c["progress"] as double? ?? 0).clamp(0.0, 1.0),
                    ),
                  )
                  .toList(),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Valmiit haasteet",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 8),
            if (completedChallenges.isEmpty)
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Ei suoritetuista haasteista merkintää.",
                  style: TextStyle(color: Colors.black54),
                ),
              )
            else
              ...completedChallenges
                  .map(
                    (c) => _progressRow(
                      c["icon"] as IconData? ?? Icons.flag,
                      c["title"] as String? ?? "",
                      1.0,
                    ),
                  )
                  .toList(),
          ],
        ],
      ),
    );
  }

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

  Widget _buildSurveyCard() {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const QuizPage()),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5A8DEE), Color(0xFF8BC6FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.assignment,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "Selvitä hyvinvointiprofiilisi",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Color(0xFF1E2A39),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Vastaa kyselyyn ja saa henkilökohtainen profiili.",
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF5D6A7C),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF5A6B82),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Curved header shape
class _CurvedHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path p = Path();
    p.lineTo(0, size.height - 80);
    p.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 80,
    );
    p.lineTo(size.width, 0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(_) => false;
}
