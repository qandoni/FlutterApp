import 'package:cloud_firestore/cloud_firestore.dart';

enum ProductStatus {
  available, // 0 - свободен
  taken, // 1 - занят
}

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imagePath;
  final ProductStatus status;
  final String? takenByUserId;
  final DateTime? takenAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imagePath,
    this.status = ProductStatus.available,
    this.takenByUserId,
    this.takenAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'image_path': imagePath,
      'status': status.index,
      'taken_by_user_id': takenByUserId,
      'taken_at': takenAt,
    };
  }

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imagePath: data['image_path'] ?? '',
      status: ProductStatus.values[data['status'] ?? 0],
      takenByUserId: data['taken_by_user_id'],
      takenAt: (data['taken_at'] as Timestamp?)?.toDate(),
    );
  }
  String get qrData => id;

  String toJson() {
    return '{"id":"$id","name":"$name","description":"$description","price":$price,"imagePath":"$imagePath","status":${status.index},"takenByUserId":${takenByUserId ?? 'null'},"takenAt":${takenAt != null ? '"${takenAt!.toIso8601String()}"' : 'null'}}';
  }

  factory Product.fromJson(String jsonString) {
    try {
      final id = _extractValue(jsonString, 'id');
      final name = _extractValue(jsonString, 'name');
      final description = _extractValue(jsonString, 'description');
      final priceStr = _extractValue(jsonString, 'price');
      final imagePath = _extractValue(jsonString, 'imagePath');
      final statusStr = _extractValue(jsonString, 'status');
      final status = statusStr.isNotEmpty
          ? ProductStatus.values[int.parse(statusStr)]
          : ProductStatus.available;
      final takenByUserIdStr = _extractValue(jsonString, 'takenByUserId');
      final takenByUserId =
          takenByUserIdStr.isNotEmpty && takenByUserIdStr != 'null'
          ? takenByUserIdStr
          : null;
      final takenAtStr = _extractValue(jsonString, 'takenAt');
      final takenAt = takenAtStr.isNotEmpty && takenAtStr != 'null'
          ? DateTime.parse(takenAtStr)
          : null;
      return Product(
        id: id,
        name: name,
        description: description,
        price: double.parse(priceStr),
        imagePath: imagePath,
        status: status,
        takenByUserId: takenByUserId,
        takenAt: takenAt,
      );
    } catch (e) {
      throw Exception('Ошибка парсинга JSON: $e');
    }
  }

  static String _extractValue(String json, String key) {
    final pattern = '"$key":\\s*"?([^",}]+)"?';
    final regex = RegExp(pattern);
    final match = regex.firstMatch(json);
    if (match != null && match.groupCount >= 1) {
      return match.group(1)!.trim();
    }
    return '';
  }

  String get statusText =>
      status == ProductStatus.available ? '✅ Доступен' : '🔴 Занят';
  String get takenInfo {
    if (status != ProductStatus.taken) return '';
    return 'Взял: ${takenByUserId ?? 'неизвестно'}, ${takenAt?.toLocal()}';
  }
}
