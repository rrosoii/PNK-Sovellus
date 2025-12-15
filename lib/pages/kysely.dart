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

  Map<String, int> profilePoints = {'Koala': 0, 'Susi': 0, 'Delfiini': 0};

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Mikä naista kannustaa sinua eniten liikkumaan?',
      'options': [
        {'text': 'Terveys ja jaksaminen', 'profile': 'Koala'},
        {'text': 'Kunnon kehittaminen ja tavoitteet', 'profile': 'Susi'},
        {'text': 'Yhteisollisyys ja hauskuus', 'profile': 'Delfiini'},
      ],
    },
    {
      'question': 'Kuinka usein harrastat hengastyttavaa liikuntaa?',
      'options': [
        {'text': 'Harvemmin kuin kerran viikossa', 'profile': 'Koala'},
        {'text': '1-3 kertaa viikossa', 'profile': 'Delfiini'},
        {'text': '3 kertaa tai enemman', 'profile': 'Susi'},
      ],
    },
    {
      'question': 'Miten koet palautuvasi arjen kuormituksesta?',
      'options': [
        {'text': 'Huonosti, olen usein vasyynyt', 'profile': 'Koala'},
        {
          'text': 'Kohtalaisesti, jaksan useimmiten hyvin',
          'profile': 'Delfiini',
        },
        {'text': 'Hyvin, palaudun nopeasti', 'profile': 'Susi'},
      ],
    },
    {
      'question': 'Mika seuraavista liikuntamuodoista kiinnostaa sinua eniten?',
      'options': [
        {
          'text': 'Kestavyys (juoksu, pyoraily)',
          'profile': 'Delfiini',
        },
        {
          'text': 'Voimaharjoittelu (kuntosali, kehonpaino)',
          'profile': 'Susi',
        },
        {
          'text': 'Liikkuvuus ja venyttely (pilates, jooga)',
          'profile': 'Koala',
        },
      ],
    },
  ];

  Future<void> _nextQuestion(int selectedIndex) async {
    final String selectedProfile =
        _questions[_currentQuestionIndex]['options'][selectedIndex]['profile'];
    profilePoints[selectedProfile] = profilePoints[selectedProfile]! + 1;

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() => _currentQuestionIndex++);
    } else {
      final String finalProfile = profilePoints.entries
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

  final Map<String, String> profileDescriptions = const {
    'Koala': 'Rauhallinen, lempea, palautuva',
    'Susi': 'Keskittynyt, analyyttinen, kunnianhimoinen',
    'Delfiini': 'Yhteisollinen, kannustava, iloinen',
  };

  final Map<String, String> profileDetails = const {
    'Koala':
        'Koala etsii arkeen hyvinvointia ja tietää levon merkityksen. Se nauttii liikkumisesta silloin kun siltä tuntuu, ja pitää tärkeimpänä hyvää oloa ja palautumista. Koala muistuttaa, että hyvinvointi on ennen kaikkea lempeyttä itseä kohtaan. Liikunta ei välttämättä ole vielä rutiini, mutta motivaatio lähtee halusta voida kokonaisvaltaisesti paremmin.',
    'Susi':
        'Susi on määrätietoinen ja voimakas. Se liikkuu säännöllisesti ja tavoitteellisesti, seuraa jälkiään tarkasti sekä toimii johdonmukaisesti. Susi haluaa kehittää itseään ja nähdä konkreettisia tuloksia. Susi innostuu datasta, mittareista ja haasteista, jotka auttavat kehittymään askel askeleelta.',
    'Delfiini':
        'Delfiini on sosiaalinen, energinen ja iloinen liikkuja, joka nauttii yhteisestä tekemisestä ja leikistä. Se saa voimaa ryhmästä ja löytää liikkumisen ilon yhdessä muiden kanssa. Delfiini muistuttaa, että hyvinvointi kasvaa jaettuna.',
  };

  void _showProfileDetailsDialog(BuildContext context) {
    final profileEmojis = {
      'Koala': '🐨',
      'Susi': '🐺',
      'Delfiini': '🐬',
    };

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${profileEmojis[profile] ?? ''} $profile',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F3C88),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    profileDetails[profile] ?? '',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F3C88),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Ymmärrän',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String description = profileDescriptions[profile] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFE7F0FF),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double circleSize =
                (constraints.biggest.shortestSide * 1.2).clamp(260.0, 480.0);

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                  const SizedBox(height: 28),
                  Container(
                    width: circleSize,
                    height: circleSize,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      profile,
                      textAlign: TextAlign.center,
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
                  GestureDetector(
                    onTap: () => _showProfileDetailsDialog(context),
                    child: const Text(
                      "Mitä hyvinvointiprofiilini tarkoittaa?",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF607C9B),
                        decoration: TextDecoration.underline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Etusivu(),
                          ),
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
