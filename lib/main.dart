import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // ✅ Imported Hive
import 'screens/home_screen.dart';
import 'screens/login_screen.dart' as login;
import 'screens/signup_screen.dart';
import 'screens/billing_screen.dart';
import 'screens/paytrack_screen.dart';
import 'screens/billing_history_screen.dart';
import 'screens/payment_list_screen.dart';
import 'screens/qr_screen.dart';
import 'screens/dashboard_screen.dart' as dashboard; // ✅ Alias to fix conflict

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter(); // ✅ Initialize Hive
  await Hive.openBox('billing_data'); // ✅ Open a Hive box for storage

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
      initialRoute: '/login',
      routes: {
        '/login': (context) => const login.LoginScreen(),
        '/signup': (context) => const SignupScreen(),

        '/home': (context) => const HomeScreen(),
        '/billing': (context) => const BillingScreen(),
        '/billing-history': (context) => const BillingHistoryScreen(),
        '/paytrack': (context) => const PayTrackScreen(),
        '/pendingList': (context) => const PaymentListPage(payments: []),
        '/qr': (context) => const QRScreen(),
        '/dashboard': (context) =>
            const dashboard.DashboardScreen(), // ✅ Fixed conflict
      },
    );
  }
}
