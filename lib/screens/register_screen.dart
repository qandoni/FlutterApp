import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/database/auth_service.dart';
import 'package:flutter_application_1/database/firestore_service.dart';
import 'package:flutter_application_1/domain/models/users.dart';
import 'package:flutter_application_1/widgets/button_app.dart';
import 'package:flutter_application_1/widgets/text_field_app.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        title: const Text("Регистрация"),
        backgroundColor: Colors.grey,
      ),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFieldApp(controller: _nameController, hintText: "Имя"),
              const SizedBox(height: 8),
              TextFieldApp(controller: _emailController, hintText: "Email"),
              const SizedBox(height: 8),
              TextFieldApp(
                controller: _passwordController,
                hintText: "Пароль",
                isObscure: true,
              ),
              const SizedBox(height: 8),
              TextFieldApp(
                controller: _confirmPasswordController,
                hintText: "Подтверждение пароля",
                isObscure: true,
              ),
              const SizedBox(height: 8),
              ButtonApp(onPressed: _register, text: "Зарегистрироваться"),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Заполните все поля")));
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Пароли не совпадают")));
      return;
    }

    try {
      final firebaseUser = await _authService.registerWithEmail(
        name,
        email,
        password,
      );
      if (firebaseUser != null) {
        final newUser = AppUser(
          id: firebaseUser.uid,
          name: name,
          email: email,
          role: UserRole.user,
        );
        await _firestoreService.createUser(newUser);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Регистрация прошла успешно!")),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Этот email уже зарегистрирован.';
          break;
        case 'weak-password':
          errorMessage = 'Пароль слишком слабый (минимум 6 символов).';
          break;
        case 'invalid-email':
          errorMessage = 'Введите корректный email адрес.';
          break;
        default:
          errorMessage = 'Ошибка регистрации: ${e.message}';
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Произошла неизвестная ошибка: $e')),
        );
      }
    }
  }
}
