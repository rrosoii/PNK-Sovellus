import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F0FF),
      appBar: AppBar(backgroundColor: Colors.blue, title: const Text("Chatti")),
      body: const Center(
        child: Text(
          "Chatti tulee myöhemmin 💬",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
