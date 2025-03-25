import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'db_model.dart';

class HiveStorage {
  static late Box<BillingData> _billingBox;

  /// ✅ Initialize Hive Database
  static Future<void> initHive() async {
    try {
      await Hive.initFlutter();
      Hive.registerAdapter(BillingDataAdapter()); // Register model adapter
      _billingBox = await Hive.openBox<BillingData>('billingBox');
    } catch (e) {
      print("Error initializing Hive: $e");
    }
  }

  /// ✅ Add a New Billing Record
  static Future<void> addBillingRecord(BillingData bill) async {
    if (!_billingBox.isOpen) await initHive();
    await _billingBox.add(bill);
  }

  /// ✅ Get All Billing Records
  static List<BillingData> getAllBillingRecords() {
    if (!_billingBox.isOpen) return [];
    return _billingBox.values.toList();
  }

  /// ✅ Delete a Billing Record
  static Future<void> deleteBillingRecord(int index) async {
    if (!_billingBox.isOpen) return;
    await _billingBox.deleteAt(index);
  }

  /// ✅ Clear All Data
  static Future<void> clearAllData() async {
    if (!_billingBox.isOpen) return;
    await _billingBox.clear();
  }
}
