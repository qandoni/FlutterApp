import 'package:flutter/material.dart';
import 'package:flutter_application_1/database/firestore_service.dart';
import 'package:flutter_application_1/domain/models/product.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class AddProductScreen extends StatefulWidget {
  final Function(Product) onProductAdded;

  const AddProductScreen({super.key, required this.onProductAdded});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  String _imagePath = "";

  Product? _generatedProduct;
  String? _qrData;

  final FirestoreService _firestoreService = FirestoreService();

  Future<bool> _requestGalleryPermission() async {
    final status = await Permission.photos.request();

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      openAppSettings();
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Нет доступа к галерее')));

    return false;
  }

  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      openAppSettings();
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Нет доступа к камере')));

    return false;
  }

  Future<void> _pickImage() async {
    final hasPermission = await _requestGalleryPermission();
    if (!hasPermission) return;

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _imagePath = image.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при выборе изображения: $e')),
      );
    }
  }

  Future<void> _takePhoto() async {
    final hasPermission = await _requestCameraPermission();
    if (!hasPermission) return;

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _imagePath = image.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка при съемке: $e')));
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Выберите изображение'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Из галереи'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Сделать фото'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Добавить товар')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Блок с изображением
                  GestureDetector(
                    onTap: _showImageSourceDialog,
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade400,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  size: 64,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Нажмите, чтобы добавить фото',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Название товара',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите название товара';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Описание',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите описание товара';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Цена',
                      border: OutlineInputBorder(),
                      suffixText: '₽',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите цену';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Введите корректное число';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton.icon(
                    onPressed: _generateQRCode,
                    icon: const Icon(Icons.qr_code),
                    label: const Text('Сгенерировать QR-код'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
            if (_qrData != null) ...[
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'QR-код товара:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    QrImageView(
                      data: _qrData!,
                      version: QrVersions.auto,
                      size: 200,
                      backgroundColor: Colors.white,
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'ID: ${_generatedProduct!.id}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _saveProduct,
                            icon: const Icon(Icons.save),
                            label: const Text('Сохранить'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _generateQRCode() {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        imagePath: _imagePath,
        status: ProductStatus.available,
        takenByUserId: null,
        takenAt: null,
      );
      setState(() {
        _generatedProduct = product;
        _qrData = product.qrData;
      });
    }
  }

  void _saveProduct() async {
    if (_generatedProduct != null) {
      // Сохраняем в Firestore
      await _firestoreService.addProduct(_generatedProduct!);
      widget.onProductAdded(_generatedProduct!);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
