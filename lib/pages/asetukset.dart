// ignore_for_file: deprecated_member_use, unused_field, unused_element, use_build_context_synchronously, prefer_const_constructors

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:pnksovellus/pages/luo_tili.dart';
import 'package:pnksovellus/pages/tietoa.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pnksovellus/pages/home.dart';
import 'package:pnksovellus/pages/log_in.dart';
import 'package:pnksovellus/routes/route_observer.dart';
import 'package:pnksovellus/services/user_data_service.dart';

class AsetuksetPage extends StatefulWidget {
  const AsetuksetPage({super.key});

  @override
  State<AsetuksetPage> createState() => _AsetuksetPageState();
}

class _AsetuksetPageState extends State<AsetuksetPage> with RouteAware {
  File? _avatarImage;
  final ImagePicker _picker = ImagePicker();
  bool ilmoitukset = true;
  String _username = "Lissu";
  bool _isLoggedIn = false;
  final UserDataService _dataService = UserDataService();

  final double innerPadding = 20;

  @override
  void initState() {
    super.initState();
    _isLoggedIn = FirebaseAuth.instance.currentUser != null;
    _loadAvatarPath();
    _loadUsername();
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
    setState(() {
      _isLoggedIn = FirebaseAuth.instance.currentUser != null;
    });
    _loadAvatarPath();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final data = await _dataService.loadProfileData();
    if (data.username.isNotEmpty) {
      setState(() => _username = data.username);
    }
  }

  Future<void> _saveUsername(String name) async {
    await _dataService.saveProfileName(name);
  }

  void _editUsername() {
    final controller = TextEditingController(text: _username);

    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: const Color(0xFFEFF4FF),
      labelText: "Nimi",
      labelStyle: const TextStyle(color: Color(0xFF2E5AAC)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF2E5AAC),
          width: 1.2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          "Muokkaa nimeä",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF224D9C),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tämä nimi näkyy sovelluksessa profiilissasi.",
              style:
                  TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              decoration: inputDecoration,
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text(
              "Peruuta",
              style: TextStyle(color: Color(0xFF2E5AAC)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF224D9C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                setState(() => _username = newName);
                _saveUsername(newName);
              }
              Navigator.of(dialogCtx).pop();
            },
            child: const Text(
              "Tallenna",
              style: TextStyle(color: Colors.white),
            ),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      backgroundColor: Colors.white,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      "Vaihda profiilikuva",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading:
                      const Icon(Icons.photo_library, color: Color(0xFF2E5AAC)),
                  title: const Text("Valitse galleriasta"),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickAvatar(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading:
                      const Icon(Icons.camera_alt, color: Color(0xFF2E5AAC)),
                  title: const Text("Ota kuva"),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickAvatar(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveAvatarPath(String path) async {
    await _dataService.saveAvatarPath(path);
  }

  Future<void> _loadAvatarPath() async {
    final data = await _dataService.loadProfileData();
    final path = data.avatarPath;
    if (path != null && File(path).existsSync()) {
      setState(() => _avatarImage = File(path));
    } else {
      setState(() => _avatarImage = null);
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    final prefs = await SharedPreferences.getInstance();
    // you might want to clear some local settings here later with prefs

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
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          "Poista tili",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFFB3261E),
          ),
        ),
        content: const Text(
          "Haluatko varmasti poistaa tilisi pysyvästi? Tätä ei voi perua.",
          style: TextStyle(height: 1.4),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        actions: [
          TextButton(
            child: const Text(
              "Peruuta",
              style: TextStyle(color: Color(0xFF2E5AAC)),
            ),
            onPressed: () => Navigator.pop(dialogCtx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB3261E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Poista",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              confirm = true;
              Navigator.pop(dialogCtx);
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

  Future<void> _showChangePasswordDialog() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kirjaudu sisään vaihtaaksesi salasanan."),
        ),
      );
      return;
    }

    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: const Color(0xFFEFF4FF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF2E5AAC),
          width: 1.2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      labelStyle: const TextStyle(color: Color(0xFF2E5AAC)),
    );

    final submitted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          "Vaihda salasana",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF224D9C),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Varmistamme ensin nykyisen salasanasi ja vaihdamme sen uuteen.",
                style: TextStyle(color: Colors.black87, height: 1.4),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: currentController,
                obscureText: true,
                decoration:
                    inputDecoration.copyWith(labelText: "Nykyinen salasana"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: newController,
                obscureText: true,
                decoration:
                    inputDecoration.copyWith(labelText: "Uusi salasana"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: confirmController,
                obscureText: true,
                decoration: inputDecoration.copyWith(
                  labelText: "Vahvista uusi salasana",
                ),
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              "Peruuta",
              style: TextStyle(color: Color(0xFF2E5AAC)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF224D9C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "Tallenna",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (submitted != true) return;

    final current = currentController.text.trim();
    final next = newController.text.trim();
    final confirm = confirmController.text.trim();

    if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Täytä kaikki kentät.")),
      );
      return;
    }
    if (next != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Uudet salasanat eivät täsmää.")),
      );
      return;
    }
    if (next.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Salasanan tulee olla vähintään 6 merkkiä."),
        ),
      );
      return;
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: current,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(next);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Salasana vaihdettu.")),
      );
    } on FirebaseAuthException catch (e) {
      String message = "Salasanan vaihto epäonnistui.";
      if (e.code == "wrong-password") {
        message = "Nykyinen salasana on virheellinen.";
      } else if (e.code == "weak-password") {
        message = "Uusi salasana on liian heikko.";
      } else if (e.code == "requires-recent-login") {
        message = "Kirjaudu uudelleen ja yritä sitten uudestaan.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Salasanan vaihto epäonnistui.")),
      );
    }
  }

  Widget _buildRow(String text, IconData icon, {VoidCallback? onTap}) {
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
          onTap: onTap,
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
                      if (_isLoggedIn)
                        _buildRow(
                          "Vaihda salasana",
                          Icons.chevron_right,
                          onTap: _showChangePasswordDialog,
                        ),
                      _buildSwitchRow("Ilmoitukset"),
                      SizedBox(height: 20),
                      _buildRow(
                        "Tietoa meistä",
                        Icons.chevron_right,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AboutUsPage(),
                            ),
                          );
                        },
                      ),
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
                                "Poista tili pysyvasti",
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
                              Icons.person_add_alt,
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
                        Center(
                          child: ListTile(
                            leading: const Icon(
                              Icons.login,
                              color: Color.fromARGB(255, 73, 108, 130),
                            ),
                            title: const Center(
                              child: Text(
                                "Kirjaudu sisaan",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 73, 108, 130),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            onTap: _goToLogin,
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
