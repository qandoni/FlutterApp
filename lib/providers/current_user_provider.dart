import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/database/firestore_service.dart';
import 'package:flutter_application_1/domain/models/users.dart';

class CurrentUserProvider extends ChangeNotifier {
  AppUser? _user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  AppUser? get user => _user;

  CurrentUserProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    print('1️⃣ _onAuthStateChanged вызван, firebaseUser = $firebaseUser');
    if (firebaseUser == null) {
      _user = null;
      print('2️⃣ Пользователь null, _user = null');
      notifyListeners();
      return;
    }

    try {
      final idTokenResult = await firebaseUser.getIdTokenResult(true);
      final claims = idTokenResult.claims;
      print('4️⃣ Токен получен, claims: $claims');

      UserRole role = UserRole.user;
      if (claims != null && claims['role'] != null) {
        final roleValue = claims['role'];
        if (roleValue is String) {
          switch (roleValue) {
            case 'admin':
              role = UserRole.admin;
              break;
            case 'manager':
              role = UserRole.manager;
              break;
          }
        } else if (roleValue is int) {
          role = UserRole.values[roleValue];
        }
      }
      print('7️⃣ Определённая роль: $role');

      Map<String, dynamic>? userData;
      try {
        userData = await _firestoreService.getUser(firebaseUser.uid);
        print('9️⃣ userData из Firestore: $userData');
      } catch (e) {
        print('Ошибка получения userData: $e');
      }

      String name = userData?['name'] ?? firebaseUser.displayName ?? '';
      String email = userData?['email'] ?? firebaseUser.email ?? '';

      if (userData == null) {
        print('📝 Документ пользователя не найден, создаём...');
        final newUser = AppUser(
          id: firebaseUser.uid,
          name: name.isNotEmpty ? name : 'Пользователь',
          email: email.isNotEmpty ? email : '',
          role: role,
        );
        await _firestoreService.createUser(newUser);
        userData = newUser.toFirestore();
        name = newUser.name;
        email = newUser.email;
      }

      _user = AppUser(
        id: firebaseUser.uid,
        name: name,
        email: email,
        role: role,
      );
      print('✅ _user установлен: ${_user?.role}');
      notifyListeners();
    } catch (e, stack) {
      print('❌ Ошибка в _onAuthStateChanged: $e');
      print(stack);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  bool get isLoggedIn => _user != null;

  bool get canCreateProducts {
    if (_user == null) return false;
    return _user!.role == UserRole.manager || _user!.role == UserRole.admin;
  }

  bool get isAdmin => _user?.role == UserRole.admin;
}
