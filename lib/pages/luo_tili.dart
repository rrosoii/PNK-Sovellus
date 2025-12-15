// ignore_for_file: file_names, unused_import, prefer_const_constructors, prefer_const_declarations, non_constant_identifier_names, use_build_context_synchronously
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:pnksovellus/pages/etusivu.dart';
import 'package:pnksovellus/pages/home.dart';
import 'package:pnksovellus/pages/kysely.dart';
import 'package:pnksovellus/pages/log_in.dart';
import 'package:pnksovellus/pages/asetukset.dart';

class Luotili extends StatelessWidget {
  const Luotili({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignUpPage(),
    );
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _passwordVisible = false;
  bool _confirmVisible = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _loading = false;

  Future<void> _createAccount() async {
    final email = _emailController.text.trim();
    final password = _passController.text.trim();
    final confirm = _confirmController.text.trim();

    if (password != confirm) {
      _showError("Salasanat eivät täsmää.");
      return;
    }
    if (email.isEmpty || password.isEmpty) {
      _showError("Sähköposti ja salasana ovat pakollisia.");
      return;
    }

    setState(() => _loading = true);

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const QuizPage()),
      );
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Jokin meni pieleen.");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF3066BE);

    return Scaffold(
      backgroundColor: const Color(0xFFE9EFFB),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new),
                        onPressed: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          } else {
                            Navigator.of(context, rootNavigator: true)
                                .maybePop();
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      const Center(
                        child: Text(
                          "Tervetuloa!",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E2A39),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      const Text("Koko nimi"),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nameController,
                        decoration: _inputDecoration("Nimi"),
                      ),

                      const SizedBox(height: 20),

                      const Text("Email"),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        decoration: _inputDecoration("Sähköposti"),
                      ),

                      const SizedBox(height: 20),

                      const Text("Salasana"),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passController,
                        obscureText: !_passwordVisible,
                        decoration: _inputDecoration("Salasana").copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(
                                () => _passwordVisible = !_passwordVisible),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text("Salasanan varmistus"),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _confirmController,
                        obscureText: !_confirmVisible,
                        decoration:
                            _inputDecoration("Salasanan vahvistus").copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _confirmVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(
                                () => _confirmVisible = !_confirmVisible),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

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
                          onPressed: _loading ? null : _createAccount,
                          child: _loading
                              ? CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  "Luo tili",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: "Onko sinulla jo tili? ",
                            style: const TextStyle(color: Colors.black87),
                            children: [
                              TextSpan(
                                text: "Kirjaudu sisään",
                                style: TextStyle(
                                  color: const Color(0xFF3066BE),
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => (Login()),
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
          },
        ),
      ),
    );
  }

  static InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
