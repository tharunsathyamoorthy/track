import 'package:hive/hive.dart';

part 'db_model.g.dart'; // Required for Hive adapter

@HiveType(typeId: 0) // Unique Type ID
class BillingData extends HiveObject {
  @HiveField(0)
  String userId;

  @HiveField(1)
  double amount;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String status;

  BillingData({
    required this.userId,
    required this.amount,
    required this.date,
    required this.status,
  });
}
