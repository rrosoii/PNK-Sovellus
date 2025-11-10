// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

void main() {
  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: QuizPage());
  }
}

class QuizPage extends StatefulWidget {
  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentQuestionIndex = 0;

  // Define your questions and options
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Mikä näistä kannustaa sinua eniten liikkumaan?',
      'options': [
        'Terveys ja jaksaminen',
        'Kunnon kehittäminen ja tavoitteet',
        'Yhteisöllisyys ja hauskuus',
      ],
    },
    {
      'question': 'Kuinka usein harrastat hengästyttävää liikuntaa?',
      'options': [
        'Harvemmin kuin kerran viikossa',
        '1-2 kertaa viikossa',
        '3 kertaa tai enemmän',
      ],
    },
    {
      'question': 'Miten koet palautuvasi arjen kuormituksesta?',
      'options': [
        'Huonosti, olen usein väsynyt',
        'Kohtalaisesti, jaksan useimmiten hyvin',
        'Hyvin, palaudun nopeasti',
      ],
    },
    {
      'question': 'Mikä seuraavista liikuntamuodoista kiinnostaa sinua eniten?',
      'options': [
        'Kestävyysharjoittelu (esim. juoksu, pyöräily)',
        'Voimaharjoittelu (esim. kuntosali, kehonpainoharjoittelu)',
        'Liikkuvuusharjoittelu ja venyttely (esim. pilates, jooga)',
      ],
    },
  ];

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      // Quiz finished
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Kiitos!'),
          content: const Text('Olet suorittanut kyselyn.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _currentQuestionIndex = 0;
                });
              },
              child: const Text('Uudelleen'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: Colors.lightBlue[50], // Soft light blue background
      appBar: AppBar(
        title: const Text('Kysely'),
        backgroundColor: Colors.lightBlue[300], // Slightly darker blue
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(value: progress, minHeight: 8),
            const SizedBox(height: 16),
            Text(
              '${_currentQuestionIndex + 1}/${_questions.length}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              question['question'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ...List.generate(question['options'].length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: Text(question['options'][index]),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
