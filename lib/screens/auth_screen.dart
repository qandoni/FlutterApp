import 'package:flutter/material.dart';
import 'package:flutter_application_1/database/auth_service.dart';
import 'package:flutter_application_1/screens/home_page.dart';
import 'package:flutter_application_1/screens/register_screen.dart';
import 'package:flutter_application_1/widgets/button_app.dart';
import 'package:flutter_application_1/widgets/text_field_app.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    _emailController.addListener(() => setState(() {}));
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E2A3E), Color(0xFF2C3E50)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              color: Colors.white.withOpacity(0.95),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.inventory_2_rounded,
                      size: 64,
                      color: Color(0xFF2C3E50),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Складской учёт',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E2A3E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Авторизация',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFieldApp(
                      controller: _emailController,
                      hintText: "Email",
                    ),
                    const SizedBox(height: 16),
                    TextFieldApp(
                      controller: _passwordController,
                      hintText: "Пароль",
                      isObscure: true,
                    ),
                    const SizedBox(height: 24),
                    ButtonApp(
                      text: "Войти",
                      onPressed: _onLogin,
                      isGradient: true,
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _onRegister,
                      child: const Text(
                        "Зарегистрироваться",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Заполните все поля")));
      return;
    }

    final userCredential = await _authService.signInWithEmail(email, password);
    if (userCredential != null) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomePage(title: "Склад"),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Неверный email или пароль")),
      );
    }
  }

  void _onRegister() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const RegisterScreen()));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
