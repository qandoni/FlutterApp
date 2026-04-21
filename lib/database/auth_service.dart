import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get user => _auth.authStateChanges();

  Future<User?> registerWithEmail(
    String name,
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          print('Этот email уже зарегистрирован.');
          rethrow;
        case 'weak-password':
          print('Пароль слишком слабый.');
          rethrow;
        case 'invalid-email':
          print('Неверный формат email.');
          rethrow;
        default:
          print('Ошибка регистрации: ${e.message}');
          rethrow;
      }
    } catch (e) {
      print('Неожиданная ошибка: $e');
      rethrow;
    }
  }

  Future<User?> signInWithEmail(String login, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: login,
        password: password,
      );
      return result.user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
