import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/domain/models/product.dart';
import 'package:flutter_application_1/domain/models/users.dart';

class FirestoreService {
  final CollectionReference _productsCollection = FirebaseFirestore.instance
      .collection('products');
  final CollectionReference _usersCollection = FirebaseFirestore.instance
      .collection('users');

  Stream<List<Product>> getProductsStream() {
    return _productsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  Future<void> addProduct(Product product) async {
    await _productsCollection.doc(product.id).set(product.toFirestore());
  }

  Future<void> updateProductStatus(
    String productId,
    ProductStatus status,
    String? takenByUserId,
    DateTime? takenAt,
  ) async {
    await _productsCollection.doc(productId).update({
      'status': status.index,
      'taken_by_user_id': takenByUserId,
      'taken_at': takenAt != null ? Timestamp.fromDate(takenAt) : null,
    });
  }

  Future<Product?> getProduct(String id) async {
    final doc = await _productsCollection.doc(id).get();
    if (doc.exists) {
      return Product.fromFirestore(doc);
    }
    return null;
  }

  Future<bool> takeProduct(String productId, String userId) async {
    try {
      await _productsCollection.doc(productId).update({
        'status': ProductStatus.taken.index,
        'taken_by_user_id': userId,
        'taken_at': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Ошибка выдачи: $e');
      return false;
    }
  }

  Future<bool> returnProduct(
    String productId,
    String userId, {
    bool isAdmin = false,
  }) async {
    try {
      final product = await getProduct(productId);
      if (product == null) return false;
      if (!isAdmin && product.takenByUserId != userId) return false;
      if (product.status != ProductStatus.taken) return false;

      await _productsCollection.doc(productId).update({
        'status': ProductStatus.available.index,
        'taken_by_user_id': null,
        'taken_at': null,
      });
      return true;
    } catch (e) {
      print('Ошибка возврата: $e');
      return false;
    }
  }

  Future<void> createUser(AppUser user) async {
    await _usersCollection.doc(user.id).set(user.toFirestore());
  }

  Future<Map<String, dynamic>?> getUser(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
    return null;
  }
}
