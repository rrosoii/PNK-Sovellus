// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  final double innerPadding = 20;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF4FF),

      body: Column(
        children: [
          // HEADER
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
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                  left: 16,
                  right: 16,
                  bottom: 10,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.settings, color: Colors.white, size: 24),
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
          ),

          // THE WHITE CARD (same look, no blue void)
          Expanded(
            child: Transform.translate(
              offset: const Offset(
                0,
                -50,
              ), // identical overlap to your screenshot
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: SingleChildScrollView(
                  padding: EdgeInsets.all(innerPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // PROFILE HEADER
                      Padding(
                        padding: EdgeInsets.only(
                          left: innerPadding * 0.2,
                          top: innerPadding * 0.5,
                          bottom: innerPadding * 0.2,
                        ),
                        child: Row(
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
                                child: _avatarImage == null
                                    ? const Icon(
                                        Icons.add_a_photo,
                                        color: Colors.grey,
                                        size: 25,
                                      )
                                    : null,
                              ),
                            ),
                            SizedBox(width: innerPadding * 0.8),
                            Expanded(
                              child: Row(
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
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: innerPadding * 1.5),
                      const Divider(height: 1, color: Color(0xFFE5E5E5)),

                      SizedBox(height: innerPadding),
                      Padding(
                        padding: EdgeInsets.only(left: innerPadding * 0.5),
                        child: const Text(
                          "Käyttäjäasetukset",
                          style: TextStyle(
                            color: Color(0xFFB2B2B2),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),

                      _buildRow("Muokkaa profiilia", Icons.chevron_right),
                      _buildRow("Vaihda salasana", Icons.chevron_right),
                      _buildRow("Lisää maksutapa", Icons.add),
                      _buildSwitchRow("Ilmoitukset"),

                      SizedBox(height: innerPadding),
                      Padding(
                        padding: EdgeInsets.only(left: innerPadding * 0.5),
                        child: const Text(
                          "Lisää",
                          style: TextStyle(
                            color: Color(0xFFB2B2B2),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),

                      _buildRow("Tietoa meistä", Icons.chevron_right),
                      _buildRow("Tietosuojakäytäntö", Icons.chevron_right),
                      _buildRow("Ehdot", Icons.chevron_right),
                      _buildRow("Personalisointi", Icons.chevron_right),

                      const SizedBox(height: 70),
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
}
