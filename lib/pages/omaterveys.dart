// ignore_for_file: unused_local_variable, deprecated_member_use

import 'package:flutter/material.dart';

class Omaterveys extends StatelessWidget {
  const Omaterveys({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'omaterveys',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFEFF4FF),
      ),
      home: const TrackerPage(),
    );
  }
}

class TrackerPage extends StatefulWidget {
  const TrackerPage({super.key});

  @override
  State<TrackerPage> createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> {
  int waterGlasses = 5;
  int steps = 3460;
  int selectedMood = 2; // 0 = sad, 1 = neutral, 2 = happy
  Map<int, int> moodMap = {}; // day -> mood index
  List<Map<String, String>> exercises = [];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top row: water tracker & moods
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Water tracker
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          setState(() {
                            if (waterGlasses > 0) waterGlasses--;
                          });
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('$waterGlasses'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          setState(() {
                            waterGlasses++;
                          });
                        },
                      ),
                    ],
                  ),

                  // Mood emojis
                  Row(
                    children: List.generate(3, (index) {
                      final colors = [Colors.blue, Colors.grey, Colors.green];
                      final moodIcons = [
                        'lib/images/sadlissu.png',
                        'lib/images/lissufaded.png',
                        'lib/images/happylissu.png',
                      ];

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedMood = index;
                            moodMap[now.day] = index;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: CircleAvatar(
                            backgroundColor: selectedMood == index
                                ? colors[index]
                                : Colors.white,
                            child: Image.asset(
                              moodIcons[index],
                              width: 24,
                              height: 24,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Step tracker
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: steps / 10000, // example max steps = 10000
                        child: Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Text('$steps / 10000 steps'),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Calendar
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: daysInMonth,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemBuilder: (context, index) {
                    final day = index + 1;
                    final mood = moodMap[day];
                    Color bgColor = Colors.white;
                    if (mood != null) {
                      bgColor = mood == 0
                          ? Colors.blue.withOpacity(0.5)
                          : mood == 1
                          ? Colors.grey.withOpacity(0.5)
                          : Colors.green.withOpacity(0.5);
                    }
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          moodMap[day] = selectedMood;
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('$day'),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Exercise log + add button
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: Column(
                children: [
                  ...exercises.map(
                    (e) => ListTile(
                      leading: const Icon(
                        Icons.directions_run,
                        color: Colors.blue,
                      ),
                      title: Text(e['type']!),
                      subtitle: Text(e['duration']!),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        exercises.add({'type': 'Juoksu', 'duration': '35 min'});
                      });
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Lisää harjoitus'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
