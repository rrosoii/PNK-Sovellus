import 'package:flutter/material.dart';
import 'package:pnksovellus/pages/omaterveys.dart';
import 'package:pnksovellus/pages/profile.dart';
import 'package:pnksovellus/widgets/app_bottom_nav.dart';
import 'support_bot.dart';

// ================= MEMORY STORE =================

class ChatMessage {
  final String sender;
  final String? text;
  final List<TextSpan>? spans;
  final String time;

  ChatMessage({
    required this.sender,
    this.text,
    this.spans,
    required this.time,
  });
}

class _ChatStore {
  final List<ChatMessage> messages = [];
}

final _chatStore = _ChatStore();

// ================= CHAT PAGE =================

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final SupportBot _bot = SupportBot();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ChatMessage> get messages => _chatStore.messages;

  bool _botTyping = false;

  // ================= SEND MESSAGE =================

  void sendMessage() {
    String text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add(ChatMessage(
        sender: "user",
        text: text,
        time: DateTime.now().toIso8601String(),
      ));

      _botTyping = true;
    });

    _scrollToBottom();
    _controller.clear();

    Future.delayed(const Duration(milliseconds: 900), () {
      List<TextSpan> replySpans = _bot.getReply(text);

      setState(() {
        _botTyping = false;

        messages.add(ChatMessage(
          sender: "bot",
          spans: replySpans,
          time: DateTime.now().toIso8601String(),
        ));
      });

      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  // ================= SWIPE NAVIGATION =================

  void _handleHorizontalSwipe(DragEndDetails details) {
    const double swipeVelocityThreshold = 400;
    double velocity = details.velocity.pixelsPerSecond.dx;

    if (velocity.abs() > swipeVelocityThreshold) {
      if (velocity > 0) {
        _navigateTo(const ProfilePage());
      } else {
        _navigateTo(const Omaterveys());
      }
    }
  }

  void _navigateTo(Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: _handleHorizontalSwipe,
      child: Scaffold(
        backgroundColor: const Color(0xFFE8F0FF),
        appBar: _buildHeader(),
        body: Column(
          children: [
            Expanded(child: _buildMessages()),
            _buildInputBar(),
          ],
        ),
        bottomNavigationBar: const AppBottomNav(currentIndex: 2),
      ),
    );
  }

  // ================= HEADER =================

  PreferredSizeWidget _buildHeader() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(85),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF2E5AAC),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: SafeArea(
          child: Row(
            children: [
              const PulsingAvatar(),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Lissu",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  SizedBox(height: 3),
                  const Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: Colors.greenAccent),
                      SizedBox(width: 6),
                      Text(
                        "online",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // ================= MESSAGES =================

  Widget _buildMessages() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      controller: _scrollController,
      reverse: true,
      itemCount: messages.length + (_botTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (_botTyping && index == 0) {
          return _buildTypingBubble();
        }

        final adjustedIndex = _botTyping ? index - 1 : index;
        final msg = messages[messages.length - 1 - adjustedIndex];

        final bool isUser = msg.sender == "user";
        final bubbleColor =
            isUser ? const Color(0xFF2E5AAC) : Colors.white;

        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 280),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 18),
                    ),
                  ),
                  child: msg.spans != null
                      ? RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color:
                                  isUser ? Colors.white : Colors.black87,
                              fontSize: 15,
                              height: 1.3,
                            ),
                            children: msg.spans!,
                          ),
                        )
                      : Text(
                          msg.text ?? "",
                          style: TextStyle(
                            color:
                                isUser ? Colors.white : Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatTime(msg.time),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= TYPING BUBBLE =================

  Widget _buildTypingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 80),
        margin: const EdgeInsets.only(top: 6, bottom: 6, left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(6),
          ),
        ),
        child: const TypingDots(),
      ),
    );
  }

  // ================= INPUT =================

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
      decoration: const BoxDecoration(color: Colors.white),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F5FB),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: "Kirjoita viesti",
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: sendMessage,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF5A8FF7), Color(0xFF2E5AAC)],
                  ),
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 18),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ================= HELPERS =================

String _formatTime(String iso) {
  final dt = DateTime.parse(iso);
  String h = dt.hour.toString().padLeft(2, '0');
  String m = dt.minute.toString().padLeft(2, '0');
  return "$h:$m";
}

// ================= TYPING DOTS =================

class TypingDots extends StatefulWidget {
  const TypingDots({super.key});

  @override
  State<TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.2).animate(
            CurvedAnimation(
              parent: _controller,
              curve: Interval(
                index * 0.15,
                index * 0.15 + 0.6,
                curve: Curves.easeInOut,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black54,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ================= PULSING AVATAR =================

class PulsingAvatar extends StatefulWidget {
  const PulsingAvatar({super.key});

  @override
  State<PulsingAvatar> createState() => _PulsingAvatarState();
}

class _PulsingAvatarState extends State<PulsingAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 2,
            )
          ],
        ),
        child: const Center(
          child: Icon(Icons.support_agent, color: Color(0xFF2E5AAC), size: 28),
        ),
      ),
    );
  }
}