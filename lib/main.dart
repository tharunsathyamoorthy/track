import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/billing_screen.dart';
import 'screens/paytrack_screen.dart';
import 'screens/billing_history_screen.dart';
import 'screens/payment_list_screen.dart'; // Import Payment List Screen
import 'screens/qr_screen.dart'; // ✅ Import QR Screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Billing App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login', // Default route
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/billing': (context) => const BillingScreen(),
        '/billing-history': (context) => const BillingHistoryScreen(),
        '/paytrack': (context) => const PayTrackScreen(),
        '/pendingList': (context) =>
            const PaymentListPage(payments: []), // ✅ Fixed constructor
        '/qr': (context) => const QRScreen(), // ✅ Added QR Code Screen
      },
    );
  }
}
