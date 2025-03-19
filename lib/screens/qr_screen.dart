import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  runApp(const QRApp());
}

class QRApp extends StatelessWidget {
  const QRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Billing App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const QRScreen(),
    );
  }
}

class QRScreen extends StatelessWidget {
  const QRScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("QR Code")),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),

              // ✅ Debug print before generating QR
              const Text(
                "Generated QR Code:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // ✅ Generated QR Code
              QrImageView(
                data: "https://example.com", // Replace with actual data
                version: QrVersions.auto,
                size: 200.0,
                gapless: false,
                embeddedImage: AssetImage("assets/images/qr_code.jpg"),
                embeddedImageStyle: QrEmbeddedImageStyle(
                  size: const Size(50, 50),
                ),
              ),

              const SizedBox(height: 20),

              // ✅ Debug print for asset image
              const Text(
                "QR Code from Asset:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Image.asset(
                "assets/images/qr_code.jpg",
                width: 200,
                height: 200,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint("❌ QR image error: $error");
                  return const Text(
                    "QR image not found!",
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
