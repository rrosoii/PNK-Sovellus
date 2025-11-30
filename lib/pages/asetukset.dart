// ignore_for_file: deprecated_member_use, unused_field, unused_element, use_build_context_synchronously, prefer_const_constructors

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:pnksovellus/pages/luo_tili.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pnksovellus/pages/home.dart';
import 'package:pnksovellus/pages/log_in.dart';

class AsetuksetPage extends StatefulWidget {
  const AsetuksetPage({super.key});

  @override
  State<AsetuksetPage> createState() => _AsetuksetPageState();
}

class _AsetuksetPageState extends State<AsetuksetPage> {
  File? _avatarImage;
  final ImagePicker _picker = ImagePicker();
  bool ilmoitukset = true;
  String _username = "Lissu";
  bool _isLoggedIn = false;

  final double innerPadding = 20;

  @override
  void initState() {
    super.initState();
    _isLoggedIn = FirebaseAuth.instance.currentUser != null;
    _loadAvatarPath();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('username');
    if (savedName != null && savedName.isNotEmpty) {
      setState(() => _username = savedName);
    }
  }

  Future<void> _saveUsername(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', name);
  }

  void _editUsername() {
    final controller = TextEditingController(text: _username);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Muokkaa nimeä"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Syötä uusi nimi"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Peruuta"),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                setState(() => _username = newName);
                _saveUsername(newName);
              }
              Navigator.of(context).pop();
            },
            child: const Text("Tallenna"),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAvatar(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, maxWidth: 600);
    if (pickedFile != null) {
      setState(() {
        _avatarImage = File(pickedFile.path);
      });
      _saveAvatarPath(pickedFile.path);
    }
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Login()),
    );
  }

  void _goToSignUp() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Luotili()),
    );
  }

  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Valitse galleriasta'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAvatar(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Ota kuva'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAvatar(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveAvatarPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('avatar_path', path);
  }

  Future<void> _loadAvatarPath() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('avatar_path');
    if (path != null && File(path).existsSync()) {
      setState(() => _avatarImage = File(path));
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    final prefs = await SharedPreferences.getInstance();
    prefs.remove('username');
    prefs.remove('avatar_path');

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Homepage()),
      (route) => false,
    );
  }

  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    bool confirm = false;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Poista tili"),
        content: const Text(
          "Haluatko varmasti poistaa tilisi pysyvästi? Tätä ei voi perua.",
        ),
        actions: [
          TextButton(
            child: const Text("Peruuta"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Poista"),
            onPressed: () {
              confirm = true;
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );

    if (!confirm) return;

    try {
      await user.delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sinun täytyy kirjautua sisään uudelleen.")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    prefs.remove('username');
    prefs.remove('avatar_path');

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Homepage()),
      (route) => false,
    );
  }

  Widget _buildRow(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 7, bottom: 5),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1),
          ),
        ),
        child: ListTile(
          dense: true,
          visualDensity: const VisualDensity(vertical: -2),
          contentPadding: EdgeInsets.zero,
          title: Text(
            text,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          trailing: Icon(icon, size: 18, color: Colors.black54),
          onTap: () {},
        ),
      ),
    );
  }

  Widget _buildSwitchRow(String text) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1)),
      ),
      child: ListTile(
        dense: true,
        visualDensity: const VisualDensity(vertical: -2),
        contentPadding: const EdgeInsets.only(left: 7),
        title: Text(
          text,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        trailing: Switch(
          value: ilmoitukset,
          activeColor: Colors.white,
          activeTrackColor: const Color.fromARGB(255, 34, 77, 156),
          onChanged: (v) => setState(() => ilmoitukset = v),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF4FF),
      body: Column(
        children: [
          Container(
            height: 150,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 34, 77, 156),
                  Color.fromARGB(255, 13, 59, 118),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.settings, color: Colors.white, size: 26),
                  const SizedBox(width: 8),
                  const Text(
                    'Asetukset',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -35),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(innerPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _showImagePickerDialog,
                            child: CircleAvatar(
                              radius: 35,
                              backgroundColor: const Color(0xFFEFF4FF),
                              backgroundImage: _avatarImage != null
                                  ? FileImage(_avatarImage!)
                                  : const AssetImage('assets/avatar.png')
                                      as ImageProvider,
                            ),
                          ),
                          SizedBox(width: 20),
                          Row(
                            children: [
                              Text(
                                _username,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF485885),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: _editUsername,
                                child: const Icon(
                                  Icons.edit,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      _buildRow("Muokkaa profiilia", Icons.chevron_right),
                      if (_isLoggedIn)
                        _buildRow("Vaihda salasana", Icons.chevron_right),
                      _buildSwitchRow("Ilmoitukset"),
                      SizedBox(height: 20),
                      _buildRow("Tietoa meistä", Icons.chevron_right),
                      _buildRow("Tietosuojakäytäntä", Icons.chevron_right),
                      _buildRow("Ehdot", Icons.chevron_right),
                      _buildRow("Personalisointi", Icons.chevron_right),
                      const SizedBox(height: 35),
                      if (_isLoggedIn) ...[
                        Center(
                          child: ListTile(
                            leading: const Icon(
                              Icons.logout,
                              color: Color.fromARGB(255, 73, 108, 130),
                            ),
                            title: const Center(
                              child: Text(
                                "Kirjaudu ulos",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 73, 108, 130),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            onTap: _logout,
                          ),
                        ),
                        Center(
                          child: ListTile(
                            leading: const Icon(
                              Icons.delete_forever,
                              color: Colors.red,
                            ),
                            title: const Center(
                              child: Text(
                                "Poista tili pysyvästi",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            onTap: _deleteAccount,
                          ),
                        ),
                      ] else ...[
                        Center(
                          child: ListTile(
                            leading: const Icon(
                              Icons.login,
                              color: Color.fromARGB(255, 73, 108, 130),
                            ),
                            title: const Center(
                              child: Text(
                                "Kirjaudu sisään",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 73, 108, 130),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            onTap: _goToLogin,
                          ),
                        ),
                        Center(
                          child: ListTile(
                            leading: const Icon(
                              Icons.login,
                              color: Color.fromARGB(255, 73, 108, 130),
                            ),
                            title: const Center(
                              child: Text(
                                "Luo tili",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 73, 108, 130),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            onTap: _goToSignUp,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
