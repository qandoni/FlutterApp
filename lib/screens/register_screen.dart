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
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              color: Colors.white.withOpacity(0.95),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.app_registration_rounded,
                      size: 64,
                      color: Color(0xFF2C3E50),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Создать аккаунт',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E2A3E),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFieldApp(
                            controller: _nameController,
                            hintText: "Имя",
                          ),
                          const SizedBox(height: 16),
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
                          const SizedBox(height: 16),
                          TextFieldApp(
                            controller: _confirmPasswordController,
                            hintText: "Подтверждение пароля",
                            isObscure: true,
                          ),
                          const SizedBox(height: 24),
                          if (_isLoading)
                            const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF2C3E50),
                              ),
                            )
                          else
                            ButtonApp(
                              onPressed: _register,
                              text: "Зарегистрироваться",
                              isGradient: true,
                            ),
                        ],
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

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar("Заполните все поля");
      return;
    }
    if (password != confirm) {
      _showSnackBar("Пароли не совпадают");
      return;
    }

    setState(() => _isLoading = true);

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
          _showSnackBar("Регистрация прошла успешно!", isError: false);
        }
      } else {
        _showSnackBar("Ошибка регистрации");
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
      _showSnackBar(errorMessage);
    } catch (e) {
      _showSnackBar('Произошла неизвестная ошибка: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
