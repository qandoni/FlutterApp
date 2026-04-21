import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:io';
import '../domain/models/product.dart'; // ваша обновлённая модель

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  bool _isAssetPath(String? path) {
    return path != null && path.startsWith('assets/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Информация о товаре'),
        backgroundColor: Colors.grey,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Карточка с изображением и основной информацией
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Изображение товара
                    Center(child: _buildProductImage()),

                    const SizedBox(height: 20),
                    const Divider(),

                    // Информация о товаре
                    _buildInfoRow('ID:', product.id),
                    const Divider(),

                    _buildInfoRow('Название:', product.name),
                    const Divider(),

                    _buildInfoRow('Описание:', product.description),
                    const Divider(),

                    _buildInfoRow('Цена:', '${product.price} ₽'),
                    const Divider(),

                    // ДОБАВЛЕНО: отображение статуса
                    _buildInfoRow('Статус:', product.statusText),
                    const Divider(),

                    // ДОБАВЛЕНО: если товар занят, показываем кто и когда взял
                    if (product.status == ProductStatus.taken) ...[
                      _buildInfoRow(
                        'Кем взят:',
                        product.takenByUserId?.toString() ?? 'неизвестно',
                      ),
                      const Divider(),
                      _buildInfoRow(
                        'Когда взят:',
                        product.takenAt != null
                            ? '${product.takenAt!.toLocal()}'
                            : 'дата неизвестна',
                      ),
                      const Divider(),
                    ],

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'QR-код товара',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          QrImageView(
                            data: product.qrData,
                            version: QrVersions.auto,
                            size: 200,
                            backgroundColor: Colors.white,
                            errorCorrectionLevel: QrErrorCorrectLevel.H,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    if (product.imagePath == null || product.imagePath!.isEmpty) {
      return _buildImagePlaceholder();
    }

    if (_isAssetPath(product.imagePath)) {
      return Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: AssetImage(product.imagePath!),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      final file = File(product.imagePath!);
      if (file.existsSync()) {
        return Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(image: FileImage(file), fit: BoxFit.cover),
          ),
        );
      } else {
        return _buildImagePlaceholder();
      }
    }
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'Нет изображения',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
