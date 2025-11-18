// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = "";
  String email = "example@email.com"; // temporary
  String profileType = "";
  File? avatarImage;

  bool editingName = false;
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    username = prefs.getString("username") ?? "Käyttäjä";
    profileType = prefs.getString("userProfile") ?? "Koala";

    // Sync email if you add it later
    String? avatarPath = prefs.getString("avatar_path");
    if (avatarPath != null && File(avatarPath).existsSync()) {
      avatarImage = File(avatarPath);
    }

    _nameController.text = username;

    setState(() {});
  }

  Future<void> _saveName(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("username", newName);
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
    );

    if (pickedFile != null) {
      avatarImage = File(pickedFile.path);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("avatar_path", pickedFile.path);

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7F0FF),
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
        _infoCard("Liittymispäivä", "20.10.2025"),
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
    return Container(
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
