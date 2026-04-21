import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  user, // 0 - обычный (только брать/возвращать)
  manager, // 1 - может создавать товары
  admin, // 2 - полный доступ
}

class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'email': email,
    'role': role.index,
  };

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: UserRole.values[data['role'] ?? 0],
    );
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? map['login'] ?? '',
      role: UserRole.values[map['role'] ?? 0],
    );
  }
}
