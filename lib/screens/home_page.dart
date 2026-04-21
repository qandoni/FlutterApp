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
        title: Text('Роль: ${currentUser?.role}'),
        backgroundColor: Colors.grey,
        actions: [
          if (canAdd)
            IconButton(
              icon: const Icon(Icons.add),
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
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: _scanQRCode,
            tooltip: 'Сканировать QR-код',
          ),
        ],
      ),
      body: StreamBuilder<List<Product>>(
        stream: _firestoreService.getProductsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }
          final products = snapshot.data ?? [];
          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Товаров пока нет',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    canAdd
                        ? 'Нажмите + чтобы добавить товар'
                        : 'Обратитесь к менеджеру для добавления товаров',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
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
    );
  }

  void _onProductAdded(Product newProduct) async {
    await _firestoreService.addProduct(newProduct);
    // Stream обновится автоматически
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Товар "${newProduct.name}" добавлен'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _scanQRCode() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const QrScannerScreen()),
    );
    if (result == true) {}
  }
}
