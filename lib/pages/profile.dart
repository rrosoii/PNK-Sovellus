import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F0FF),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Profiili"),
      ),
      body: const Center(
        child: Text(
          "Profiilisivu tulee pian 👤",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
