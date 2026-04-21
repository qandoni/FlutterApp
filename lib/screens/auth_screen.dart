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
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Авторизация',
              style: TextStyle(fontSize: 38, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextFieldApp(controller: _emailController, hintText: "Email"),
            const SizedBox(height: 8),
            TextFieldApp(
              controller: _passwordController,
              hintText: "Пароль",
              isObscure: true,
            ),
            const SizedBox(height: 8),
            ButtonApp(text: "Войти", onPressed: _onLogin),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _onRegister,
              child: const Text(
                "Зарегистрироваться",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          ],
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

    // Вход через Firebase Auth
    final userCredential = await _authService.signInWithEmail(email, password);
    if (userCredential != null) {
      // Провайдер сам подхватит пользователя через подписку, явно вызывать setUser не нужно
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomePage(title: "Список товаров"),
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
