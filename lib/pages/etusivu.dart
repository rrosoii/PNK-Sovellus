import 'package:flutter/material.dart';

class Etusivu extends StatelessWidget {
  const Etusivu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF4FF),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Etusivu'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Tilastot'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Terveys'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profiili'),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔍 Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Hae artikkeleja',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 👋 Greeting
                const Text(
                  'Tervetuloa takaisin!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(72, 88, 133, 1.0),
                  )
                ),
                const SizedBox(height: 12),

                // 📰 Swipable Articles
                SizedBox(
                  height: 180,
                  child: PageView.builder(
                    controller: PageController(viewportFraction: 0.9),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                child: Image.asset(
                                  'assets/article.jpg', // replace with your image
                                  height: 100,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Influenssarokote tehokkain suoja influenssaa ja sen jälkitauteja vastaan',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text('20.10.2025', style: TextStyle(color: Colors.grey)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),

                // 🏅 Achievements
                const Text('Saavutukset', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    Icon(Icons.local_fire_department, color: Colors.deepOrange, size: 40),
                    Icon(Icons.bolt, color: Colors.green, size: 40),
                    Icon(Icons.water_drop, color: Colors.blue, size: 40),
                  ],
                ),
                const SizedBox(height: 30),

                // 💪 Recommended Challenges
                const Text('Sinulle suositellut haasteet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 100,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
                          ],
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Kävelyhaaste', style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              Text('Kävele 10 000 askelta joka päivä viikon ajan'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
                          ],
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Juomahaaste', style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              Text('Juo 5 lasia vettä joka päivä viikon ajan'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // 📚 Articles Section
                const Text('Artikkelit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    CategoryChip(icon: Icons.bedtime, label: 'Uni'),
                    CategoryChip(icon: Icons.apple, label: 'Ravinto'),
                    CategoryChip(icon: Icons.favorite, label: 'Sydän'),
                    CategoryChip(icon: Icons.flash_on, label: 'Energia'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Small helper widget
class CategoryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const CategoryChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.white,
          child: Icon(icon, color: Colors.blue),
        ),
        const SizedBox(height: 6),
        Text(label),
      ],
    );
  }
}
