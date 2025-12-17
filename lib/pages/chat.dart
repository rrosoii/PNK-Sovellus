import 'package:flutter/material.dart';
import 'package:pnksovellus/pages/omaterveys.dart';
import 'package:pnksovellus/pages/profile.dart';
import 'package:pnksovellus/widgets/app_bottom_nav.dart';
import 'support_bot.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

// Simple in-memory store so chat history survives tab changes.
class _ChatStore {
  final List<Map<String, String>> messages = [];
}

final _chatStore = _ChatStore();

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final SupportBot _bot = SupportBot();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, String>> get messages => _chatStore.messages;

  bool _botTyping = false;

  void sendMessage() {
    String text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({
        "sender": "user",
        "text": text,
        "time": DateTime.now().toIso8601String(),
      });

      _botTyping = true;
    });

    _scrollToBottom();

    _controller.clear();

    Future.delayed(const Duration(milliseconds: 900), () {
      String reply = _bot.getReply(text);

      setState(() {
        _botTyping = false;
        messages.add({
          "sender": "bot",
          "text": reply,
          "time": DateTime.now().toIso8601String(),
        });
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

  // Keep recognizers so we can dispose them to avoid leaks
  final List<TapGestureRecognizer> _linkRecognizers = [];

  Widget _buildMessageText(String text, bool isUser) {
    final baseStyle = TextStyle(
      color: isUser ? Colors.white : Colors.black87,
      fontSize: 15,
      height: 1.3,
    );

    final urlRegex = RegExp(r'(https?:\/\/[^\s]+)');
    final matches = urlRegex.allMatches(text).toList();
    if (matches.isEmpty) {
      return Text(text, style: baseStyle);
    }

    final spans = <TextSpan>[];
    int lastIndex = 0;

    for (final m in matches) {
      if (m.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, m.start), style: baseStyle));
      }

      final url = text.substring(m.start, m.end);
      final recognizer = TapGestureRecognizer()
        ..onTap = () async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        };

      _linkRecognizers.add(recognizer);

      spans.add(TextSpan(
        text: url,
        style: baseStyle.copyWith(
          color: isUser ? Colors.white : Colors.blue,
          decoration: TextDecoration.underline,
        ),
        recognizer: recognizer,
      ));

      lastIndex = m.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex), style: baseStyle));
    }

    return RichText(text: TextSpan(children: spans, style: baseStyle));
  }

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
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black.withValues(alpha: 0.08),
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const TypingDots(),
      ),
    );
  }

  void _handleHorizontalSwipe(DragEndDetails details) {
    const double swipeVelocityThreshold = 400; // pixels per second
    double velocity = details.velocity.pixelsPerSecond.dx;

    if (velocity.abs() > swipeVelocityThreshold) {
      if (velocity > 0) {
        // Swipe right → go to Omaterveys
        _navigateTo(const ProfilePage());
      } else {
        // Swipe left → go to Asetukset
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

  @override
  void dispose() {
    for (final r in _linkRecognizers) {
      r.dispose();
    }
    _linkRecognizers.clear();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  // ===================== HEADER =====================

  PreferredSizeWidget _buildHeader() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(85),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF2E5AAC),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              color: Colors.black12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: const SafeArea(
          child: Row(
            children: [
              PulsingAvatar(),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Lissu",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  SizedBox(height: 3),
                  Row(
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

  // ===================== MESSAGES =====================

  Widget _buildMessages() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      controller: _scrollController,
      reverse: true,
      itemCount: messages.length + (_botTyping ? 1 : 0),
      itemBuilder: (context, index) {
        // typing indicator visit
        if (_botTyping && index == 0) {
          return _buildTypingBubble();
        }

        final adjustedIndex = _botTyping ? index - 1 : index;
        final msg = messages[messages.length - 1 - adjustedIndex];

        final bool isUser = msg["sender"] == "user";
        final Color bubbleColor =
            isUser ? const Color(0xFF2E5AAC) : Colors.white;

        return AnimatedOpacity(
            opacity: 1,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: Align(
              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: isUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
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
                        boxShadow: isUser
                            ? []
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: _buildMessageText(msg["text"] ?? "", isUser),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatTime(
                          msg["time"] ?? DateTime.now().toIso8601String()),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ));
      },
    );
  }

  // ===================== INPUT BAR =====================

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            offset: Offset(0, -1),
            color: Colors.black12,
          ),
        ],
      ),
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
                  textCapitalization: TextCapitalization.sentences,
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

  // ===================== BOTTOM NAV =====================

  Widget _buildBottomNav() {
    return const AppBottomNav(currentIndex: 2);
  }
}

String _formatTime(String iso) {
  final dt = DateTime.parse(iso);
  String h = dt.hour.toString().padLeft(2, '0');
  String m = dt.minute.toString().padLeft(2, '0');
  return "$h:$m";
}


class TypingDots extends StatefulWidget {
  const TypingDots({super.key});

  @override
  State<TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _dot(int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final phase = (_controller.value * 3) - index;
        final double bounce =
            (phase < 0 || phase > 1) ? 0 : (1 - (phase - 0.5).abs() * 2);

        return Transform.translate(
          offset: Offset(0, -6 * bounce),
          child: Opacity(
            opacity: 0.4 + (bounce * 0.6),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF2E5AAC),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 26,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _dot(0),
          _dot(1),
          _dot(2),
        ],
      ),
    );
  }
}

class PulsingAvatar extends StatefulWidget {
  const PulsingAvatar({super.key});

  @override
  State<PulsingAvatar> createState() => _PulsingAvatarState();
}

class _PulsingAvatarState extends State<PulsingAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        return Transform.scale(
          scale: 1 + (_controller.value * 0.04),
          child: child,
        );
      },
      child: const CircleAvatar(
        backgroundColor: Colors.white,
        backgroundImage: AssetImage('lib/images/lissu_chatti.png'),
        radius: 30,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
