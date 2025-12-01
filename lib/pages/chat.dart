import 'package:flutter/material.dart';
import 'support_bot.dart';
import 'package:pnksovellus/widgets/app_bottom_nav.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final SupportBot _bot = SupportBot();
  final TextEditingController _controller = TextEditingController();

  List<Map<String, String>> messages = [];

  void sendMessage() {
    String text = _controller.text.trim();
    if (text.isEmpty) return;

    // User message
    setState(() {
      messages.add({"sender": "user", "text": text});
    });

    _controller.clear();

    // Bot reply
    Future.delayed(const Duration(milliseconds: 300), () {
      String reply = _bot.getReply(text);

      setState(() {
        messages.add({"sender": "bot", "text": reply});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F0FF),
      appBar: AppBar(backgroundColor: Colors.blue, title: const Text("Chatti")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                bool isUser = msg["sender"] == "user";

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg["text"] ?? "",
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Write a message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }
}
