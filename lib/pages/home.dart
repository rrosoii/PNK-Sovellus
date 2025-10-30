import 'package:flutter/material.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 227, 235, 253),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //logo
            Image.asset('lib/images/pnk-sininen-fi.png', height: 200),

            //text
            Text(
              'Tervetuloa!',
              style: TextStyle(
                color: const Color.fromRGBO(13, 59, 128, 1),
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),

            ElevatedButton(
              onPressed: () {},
              child: Text(
                'Luo Tili',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
