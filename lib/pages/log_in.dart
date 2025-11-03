import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:pnksovellus/pages/etusivu.dart';
import 'package:pnksovellus/pages/luo-tili.dart';

void main() => runApp(const Login());

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _passwordVisible = false;
  final bool _emailVisible = true;

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF3066BE);
    return Scaffold(
      backgroundColor: const Color(0xFFE9EFFB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () {},
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "Tervetuloa takaisin!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2A39),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Text("Email"),
              const SizedBox(height: 8),
              TextField(
                obscureText: !_emailVisible,
                decoration: _inputDecoration(
                  "matti.meikalainen@gmail.com",
                ).copyWith(),
              ),
              const SizedBox(height: 20),
              const Text("Salasana"),
              const SizedBox(height: 8),
              TextField(
                obscureText: !_passwordVisible,
                decoration: _inputDecoration("Salasana123!").copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _passwordVisible = !_passwordVisible),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Etusivu()),
                    );
                  },
                  child: const Text(
                    "Kirjaudu sisään",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: RichText(
                  text: TextSpan(
                    text: "Puuttuuko sinulta tili? ",
                    style: const TextStyle(color: Colors.black87),
                    children: [
                      TextSpan(
                        text: "Luo tili",
                        style: TextStyle(
                          color: const Color(0xFF3066BE),
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => (Luotili()),
                              ),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 14.0,
        horizontal: 16.0,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
