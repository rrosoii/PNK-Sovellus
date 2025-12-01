// ignore_for_file: deprecated_member_use, use_build_context_synchronously, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:pnksovellus/pages/etusivu.dart';
import 'package:pnksovellus/services/user_data_service.dart';

void main() {
  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: QuizPage(),
    );
  }
}

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentQuestionIndex = 0;
  final UserDataService _dataService = UserDataService();

  // Profile points tally
  Map<String, int> profilePoints = {'Koala': 0, 'Susi': 0, 'Delfiini': 0};

  // Quiz questions with profile mapping for each option
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Mikä näistä kannustaa sinua eniten liikkumaan?',
      'options': [
        {'text': 'Terveys ja jaksaminen', 'profile': 'Koala'},
        {'text': 'Kunnon kehittäminen ja tavoitteet', 'profile': 'Susi'},
        {'text': 'Yhteisöllisyys ja hauskuus', 'profile': 'Delfiini'},
      ],
    },
    {
      'question': 'Kuinka usein harrastat hengästyttävää liikuntaa?',
      'options': [
        {'text': 'Harvemmin kuin kerran viikossa', 'profile': 'Koala'},
        {'text': '1-3 kertaa viikossa', 'profile': 'Delfiini'},
        {'text': '3 kertaa tai enemmän', 'profile': 'Susi'},
      ],
    },
    {
      'question': 'Miten koet palautuvasi arjen kuormituksesta?',
      'options': [
        {'text': 'Huonosti, olen usein väsynyt', 'profile': 'Koala'},
        {
          'text': 'Kohtalaisesti, jaksan useimmiten hyvin',
          'profile': 'Delfiini',
        },
        {'text': 'Hyvin, palaudun nopeasti', 'profile': 'Susi'},
      ],
    },
    {
      'question': 'Mikä seuraavista liikuntamuodoista kiinnostaa sinua eniten?',
      'options': [
        {
          'text': 'Kestävyysharjoittelu (esim. juoksu, pyöräily)',
          'profile': 'Delfiini',
        },
        {
          'text': 'Voimaharjoittelu (esim. kuntosali, kehonpainoharjoittelu)',
          'profile': 'Susi',
        },
        {
          'text': 'Liikkuvuusharjoittelu ja venyttely (esim. pilates, jooga)',
          'profile': 'Koala',
        },
      ],
    },
  ];

  // Handle option selection
  Future<void> _nextQuestion(int selectedIndex) async {
    String selectedProfile =
        _questions[_currentQuestionIndex]['options'][selectedIndex]['profile'];
    profilePoints[selectedProfile] = profilePoints[selectedProfile]! + 1;

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() => _currentQuestionIndex++);
    } else {
      // Determine final profile (highest points)
      String finalProfile = profilePoints.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;

      await _dataService.saveProfileType(finalProfile);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HealthProfileScreen(profile: finalProfile),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFFE7F0FF),
      body: SafeArea(
        child: Stack(
          children: [
            // Bottom-left mascot image (use available asset)
            Align(
              alignment: Alignment.bottomLeft,
              child: Image.asset(
                'assets/character.png',
                height: 180,
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GradientProgressBar(progress: progress),
                  const SizedBox(height: 8),
                  Text(
                    '${_currentQuestionIndex + 1}/${_questions.length}',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    question['question'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F3C88),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ...List.generate(question['options'].length, (index) {
                    final optionText = question['options'][index]['text'];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: GestureDetector(
                        onTap: () => _nextQuestion(index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 28,
                                width: 28,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE7F0FF),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFF1F3C88),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + index),
                                    style: const TextStyle(
                                      color: Color(0xFF1F3C88),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  optionText,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GradientProgressBar extends StatelessWidget {
  final double progress;
  const GradientProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 12, 77, 162),
                    Color.fromARGB(255, 4, 29, 60),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HealthProfileScreen extends StatelessWidget {
  final String profile;
  const HealthProfileScreen({super.key, required this.profile});

  // Descriptions for each profile
  final Map<String, String> profileDescriptions = const {
    'Koala': 'Rauhallinen, lempeä, palautuva',
    'Susi': 'keskittynyt, analyyttinen, kunnianhimoinen',
    'Delfiini': 'Yhteisöllinen, kannustava, iloinen',
  };

  @override
  Widget build(BuildContext context) {
    String description = profileDescriptions[profile] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFE7F0FF),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 40),
            Column(
              children: [
                const Text(
                  "Sinun hyvinvointiprofiilisi on",
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F3C88),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Large circle with profile name
                Container(
                  width: 500,
                  height: 500,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    profile,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F3C88),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1F3C88),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Mitä hyvinvointiprofiilini tarkoittaa?",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF607C9B),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to home screen or previous screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Etusivu()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F3C88),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "Selvä!",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
