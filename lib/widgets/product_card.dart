// В вашем ProductCard виджете
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/domain/models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: [
          // Изображение товара
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: _buildProductImage(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(product.description),
                  Text(
                    '${product.price} ₽',
                    style: const TextStyle(fontSize: 16, color: Colors.green),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    // Проверяем, является ли путь asset'ом или файловым путем
    if (product.imagePath.startsWith('assets/')) {
      // Это asset изображение
      return Image.asset(
        product.imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorImage();
        },
      );
    } else {
      // Это файловое изображение (с камеры или галереи)
      final file = File(product.imagePath);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Ошибка загрузки файла: $error');
            return _buildErrorImage();
          },
        );
      } else {
        print('Файл не существует: ${product.imagePath}');
        return _buildErrorImage();
      }
    }
  }

  Widget _buildErrorImage() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
      ),
    );
  }
}
