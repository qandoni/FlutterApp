// lib/screens/qr_scanner_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/database/firestore_service.dart';
import 'package:flutter_application_1/domain/models/product.dart';
import 'package:flutter_application_1/domain/models/users.dart';
import 'package:flutter_application_1/providers/current_user_provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<CurrentUserProvider>(context).user!;

    return Scaffold(
      appBar: AppBar(title: const Text('Сканер QR-кода')),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) => _handleBarcode(capture, currentUser),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Наведите камеру на QR-код товара',
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleBarcode(
    BarcodeCapture capture,
    AppUser currentUser,
  ) async {
    if (_isProcessing) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.firstWhere(
      (b) => b.format == BarcodeFormat.qrCode,
      orElse: () => barcodes.first,
    );
    final scannedData = barcode.displayValue;
    if (scannedData == null) return;

    await _controller.stop();
    setState(() => _isProcessing = true);

    try {
      String productId;
      try {
        final product = Product.fromJson(scannedData);
        productId = product.id;
      } catch (e) {
        productId = scannedData.trim();
      }

      final product = await _firestoreService.getProduct(productId);

      if (product == null) {
        _showResult('Товар с кодом "$productId" не найден', isError: true);
        setState(() => _isProcessing = false);
        await _controller.start();
        return;
      }

      if (product.status == ProductStatus.available) {
        final success = await _firestoreService.takeProduct(
          productId,
          currentUser.id,
        );
        if (success) {
          _showResult(
            'Товар "${product.name}" выдан пользователю ${currentUser.name}',
          );
          Navigator.pop(context, true);
          return;
        } else {
          _showResult('Ошибка выдачи товара', isError: true);
        }
      } else {
        final isAdmin = Provider.of<CurrentUserProvider>(
          context,
          listen: false,
        ).isAdmin;
        final success = await _firestoreService.returnProduct(
          productId,
          currentUser.id,
          isAdmin: isAdmin,
        );
        if (success) {
          _showResult('Товар "${product.name}" возвращен на склад');
          Navigator.pop(context, true);
          return;
        } else {
          final freshProduct = await _firestoreService.getProduct(productId);
          if (freshProduct != null &&
              freshProduct.status == ProductStatus.taken &&
              freshProduct.takenByUserId != currentUser.id &&
              !isAdmin) {
            _showResult(
              'Вы не можете вернуть этот товар (он взят другим пользователем)',
              isError: true,
            );
          } else {
            _showResult('Ошибка возврата товара', isError: true);
          }
        }
      }
      setState(() => _isProcessing = false);
      await _controller.start();
    } catch (e) {
      _showResult('Ошибка: $e', isError: true);
      setState(() => _isProcessing = false);
      await _controller.start();
    }
  }

  void _showResult(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
