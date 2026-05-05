import 'package:flutter/material.dart';
import 'package:flutter_application_1/database/firestore_service.dart';
import 'package:flutter_application_1/domain/models/users.dart';
import 'package:flutter_application_1/providers/current_user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/domain/models/product.dart';
import 'package:flutter_application_1/screens/product_detail_page.dart';
import 'package:flutter_application_1/screens/add_product_screen.dart';
import 'package:flutter_application_1/screens/qr_scanner_screen.dart';
import 'package:flutter_application_1/widgets/product_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<CurrentUserProvider>(context).user;
    final canAdd =
        currentUser != null &&
        (currentUser.role == UserRole.manager ||
            currentUser.role == UserRole.admin);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.warehouse, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(color: Color.fromARGB(255, 38, 137, 177)),
        elevation: 0,
        centerTitle: false,
        actions: [
          if (canAdd)
            IconButton(
              icon: const Icon(Icons.add_box_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddProductScreen(onProductAdded: _onProductAdded),
                  ),
                );
              },
              tooltip: 'Добавить товар',
            ),
        ],
      ),
      body: StreamBuilder<List<Product>>(
        stream: _firestoreService.getProductsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 38, 137, 177),
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Ошибка: ${snapshot.error}'),
                ],
              ),
            );
          }
          final products = snapshot.data ?? [];
          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: Color.fromARGB(255, 38, 137, 177),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Склад пуст',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 38, 137, 177),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    canAdd
                        ? 'Нажмите + чтобы добавить первый товар'
                        : 'Добавление товаров доступно только менеджеру',
                    style: const TextStyle(
                      color: Color.fromARGB(255, 38, 137, 177),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductDetailPage(product: product),
                      ),
                    );
                  },
                  child: ProductCard(product: product),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scanQRCode,
        tooltip: 'Сканировать QR-код',
        backgroundColor: const Color.fromARGB(255, 38, 137, 177),
        child: const Icon(Icons.qr_code_scanner_rounded),
      ),
    );
  }

  void _onProductAdded(Product newProduct) async {
    await _firestoreService.addProduct(newProduct);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Товар "${newProduct.name}" добавлен'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _scanQRCode() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const QrScannerScreen()),
    );
  }
}
