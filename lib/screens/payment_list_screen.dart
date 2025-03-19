import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PaymentListPage extends StatefulWidget {
  final List<Map<String, dynamic>> payments;
  final String searchQuery;

  const PaymentListPage({
    Key? key,
    required this.payments,
    this.searchQuery = '',
  }) : super(key: key);

  @override
  _PaymentListPageState createState() => _PaymentListPageState();
}

class _PaymentListPageState extends State<PaymentListPage> {
  List<Map<String, dynamic>> payments = [];
  String searchQuery = "";
  bool showPendingOnly = false;

  @override
  void initState() {
    super.initState();
    searchQuery = widget.searchQuery;
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString('payments');

    if (savedData != null) {
      setState(() {
        payments = List<Map<String, dynamic>>.from(json.decode(savedData));
      });
    } else {
      setState(() {
        payments = widget.payments;
      });
      _savePayments();
    }
  }

  Future<void> _savePayments() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('payments', json.encode(payments));
  }

  void handleUpdateStatus(String id, String newStatus) {
    setState(() {
      final index = payments.indexWhere((payment) => payment['id'] == id);
      if (index != -1) {
        payments[index]['status'] = newStatus;
        _savePayments();
      }
    });
  }

  void handleDeletePayment(String id) {
    setState(() {
      payments.removeWhere((payment) => payment['id'] == id);
      _savePayments();
    });
  }

  Map<String, List<Map<String, dynamic>>> groupPaymentsByMobile(
      List<Map<String, dynamic>> filteredPayments) {
    Map<String, List<Map<String, dynamic>>> groupedPayments = {};

    for (var payment in filteredPayments) {
      String mobileNumber = payment["mobile number"];

      if (!groupedPayments.containsKey(mobileNumber)) {
        groupedPayments[mobileNumber] = [];
      }
      groupedPayments[mobileNumber]!.add(payment);
    }

    return groupedPayments;
  }

  List<Map<String, dynamic>> _getFilteredPayments() {
    return payments.where((payment) {
      final customerName = payment["customer"].toString().toLowerCase();
      final mobileNumber = payment["mobile number"].toString();
      final query = searchQuery.toLowerCase();

      bool matchesSearch = query.isEmpty ||
          customerName.contains(query) ||
          mobileNumber.contains(query);

      bool matchesPendingFilter =
          !showPendingOnly || payment["status"] == "Pending";

      return matchesSearch && matchesPendingFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredPayments = _getFilteredPayments();
    final groupedPayments = groupPaymentsByMobile(filteredPayments);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Payments"),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.tealAccent],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: "Search",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              groupedPayments.isEmpty
                  ? const Expanded(
                      child: Center(
                        child: Text(
                          "No payments found.",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: groupedPayments.length,
                        itemBuilder: (context, index) {
                          String mobileNumber =
                              groupedPayments.keys.elementAt(index);
                          List<Map<String, dynamic>> customerPayments =
                              groupedPayments[mobileNumber]!;

                          double totalPendingAmount = customerPayments
                              .where(
                                  (payment) => payment["status"] == "Pending")
                              .fold(
                                  0,
                                  (sum, item) =>
                                      sum +
                                      (double.tryParse(
                                              item["amount"].toString()) ??
                                          0));

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: ExpansionTile(
                              title: Text(customerPayments[0]["customer"],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                "📞 Mobile: $mobileNumber\n"
                                "💰 Total Pending: ₹${totalPendingAmount.toStringAsFixed(2)}",
                                style: const TextStyle(fontSize: 14),
                              ),
                              children: customerPayments.map((payment) {
                                return ListTile(
                                  title:
                                      Text("💰 Amount: ₹${payment["amount"]}"),
                                  subtitle: Text("📅 Date: ${payment["date"]}"),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      DropdownButton<String>(
                                        value: payment["status"],
                                        onChanged: (newStatus) {
                                          if (newStatus != null) {
                                            handleUpdateStatus(
                                                payment["id"], newStatus);
                                          }
                                        },
                                        items: ["Pending", "Paid"]
                                            .map(
                                              (status) => DropdownMenuItem(
                                                value: status,
                                                child: Text(
                                                  status,
                                                  style: TextStyle(
                                                      color: status == "Pending"
                                                          ? Colors.orange
                                                          : Colors.green),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () =>
                                            _showDeleteConfirmation(
                                                context, payment["id"]),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String paymentId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Delete Payment"),
          content: const Text("Are you sure you want to delete this payment?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                handleDeletePayment(paymentId);
                Navigator.pop(dialogContext);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
