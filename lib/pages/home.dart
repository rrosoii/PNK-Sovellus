import 'package:flutter/material.dart';
import 'package:pnksovellus/pages/log-in.dart';
import 'package:pnksovellus/pages/luo-tili.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return const WelcomePage();
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 227, 235, 253),
      body: SafeArea(
        child: Stack(
          children: [
            // decorative circles top-left
            Positioned(
              top: -30,
              left: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(46, 90, 172, 0.18),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: -30,
              left: 45,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(46, 90, 172, 0.14),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // main content
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // push content down so buttons/texts aren't too high
                const SizedBox(height: 120),

                // logo
                Center(
                  child: Image.asset(
                    'lib/images/pnk-sininen-fi.png',
                    height: 250,
                  ),
                ),

                const SizedBox(height: 18),

                // welcome text
                const Center(
                  child: Text(
                    'Tervetuloa!',
                    style: TextStyle(
                      color: Color.fromRGBO(13, 59, 128, 1),
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                ),

                const SizedBox(height: 80),

                // primary button
                Center(
                  child: SizedBox(
                    width: screenWidth * 0.67,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E5AAC),
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Luotili()),
                        );
                      },
                      child: const Text(
                        'Luo tili',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // small prompt + login
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Onko sinulla jo tili ?',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(width: 0),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Login()),
                          );
                        },
                        child: const Text(
                          'Kirjaudu sisään.',
                          style: TextStyle(
                            color: Color.fromRGBO(13, 59, 128, 1),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // secondary bottom action
                Center(
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'Selaa kirjautumatta >',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 110, 111, 118),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
