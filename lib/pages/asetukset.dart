import 'package:flutter/material.dart';

class AsetuksetPage extends StatefulWidget {
  const AsetuksetPage({super.key});

  @override
  State<AsetuksetPage> createState() => _AsetuksetPageState();
}

class _AsetuksetPageState extends State<AsetuksetPage> {
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF4FF),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 60,
              left: 16,
              right: 16,
              bottom: 24,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2962FF), Color(0xFF0039CB)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.settings, color: Colors.white, size: 28),
                const SizedBox(width: 8),
                const Text(
                  "Asetukset",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User section
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.blue[100],
                            backgroundImage: const AssetImage(
                              'assets/icons/happylissu.png',
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Lissu",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "Käyttäjäasetukset",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  _buildSettingsTile("Muokkaa profiilia", Icons.person_outline),
                  _buildSettingsTile("Vaihda salasana", Icons.lock_outline),
                  _buildSettingsTile("Lisää maksutapa", Icons.add),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: Colors.blue,
                    title: const Text("Ilmoitukset"),
                    value: notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        notificationsEnabled = value;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "Lisää",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  _buildSettingsTile("Tietoa meistä", Icons.info_outline),
                  _buildSettingsTile(
                    "Tietosuojakäytäntö",
                    Icons.privacy_tip_outlined,
                  ),
                  _buildSettingsTile("Ehdot", Icons.description_outlined),
                  _buildSettingsTile("Personalisointi", Icons.tune),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(String title, IconData icon) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}
