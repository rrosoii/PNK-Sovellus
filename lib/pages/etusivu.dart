import 'package:flutter/material.dart';

class Etusivu extends StatelessWidget {
  const Etusivu({super.key});

  @override
  Widget build(BuildContext context) {
    const double topOffset = 200; // vertical offset from top of content

    return Scaffold(
      backgroundColor: const Color(0xFFEFF4FF),
      bottomNavigationBar: BottomNavigationBar(
        // ...existing bottomNavigationBar code stays the same...
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

      body: Stack(
        children: [
          // fixed top-right icons (optional)
          Positioned(
            top: 22,
            right: 16,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                  color: Colors.transparent,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.notifications, color: Colors.blue, size: 25),
                    tooltip: 'Ilmoitukset',
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 2),
                Material(
                  color: Colors.transparent,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.settings, color: Colors.blue, size: 25),
                    tooltip: 'Asetukset',
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),

          // Scrollable area with circle painted first so it stays behind content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Stack(
                  children: [
                    // Background circle with OverflowBox to allow unlimited size
                    Align(
                      alignment: Alignment.topCenter,
                      child: OverflowBox(
                        maxWidth: double.infinity,
                        maxHeight: double.infinity,
                        child: Container(
                          margin: const EdgeInsets.only(top: topOffset),
                          width: 2000,  // can be any size now
                          height: 2000, // can be any size now
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    // Main content above the circle - rest stays the same
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search Bar
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

                        // Greeting
                        const Text(
                          'Tervetuloa takaisin!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(72, 88, 133, 1),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Swipable Articles with elevation
                        SizedBox(
                          height: 180,
                          child: PageView.builder(
                            controller: PageController(viewportFraction: 0.9),
                            itemCount: 3,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Material(
                                  elevation: 8,
                                  shadowColor: Colors.black.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(16),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      color: Colors.white,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Image.asset(
                                            'assets/article.jpg',
                                            height: 100,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
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
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Achievements with gradient text
                        Center(
                          child: ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF485885), Color(0xFF2196F3)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ).createShader(bounds),
                            child: const Text(
                              'Saavutukset',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
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

                        // Recommended Challenges
                        const Text('Sinulle suositellut haasteet', 
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
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
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
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

                        // Articles categories
                        const Text('Artikkelit', 
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

                        const SizedBox(height: 140),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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