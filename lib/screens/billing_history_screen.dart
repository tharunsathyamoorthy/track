import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BillingHistoryScreen extends StatefulWidget {
  const BillingHistoryScreen({super.key});

  @override
  _BillingHistoryScreenState createState() => _BillingHistoryScreenState();
}

class _BillingHistoryScreenState extends State<BillingHistoryScreen> {
  List<Map<String, dynamic>> billingHistory = [];

  @override
  void initState() {
    super.initState();
    _loadBillingHistory();
  }

  Future<void> _loadBillingHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? history = prefs.getStringList('billingHistory');

    setState(() {
      billingHistory = history
              ?.map((bill) {
                try {
                  return jsonDecode(bill) as Map<String, dynamic>;
                } catch (e) {
                  print("Error decoding bill: $e");
                  return <String, dynamic>{};
                }
              })
              .where((bill) => bill.isNotEmpty)
              .toList() ??
          [];
    });
  }

  Future<void> _deleteBill(int index) async {
    if (index < 0 || index >= billingHistory.length) return;

    billingHistory.removeAt(index);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'billingHistory', billingHistory.map(jsonEncode).toList());

    setState(() {}); // Ensure UI updates after deletion
  }

  Future<void> _downloadBill(int index) async {
    if (index < 0 || index >= billingHistory.length) return;

    final bill = billingHistory[index];
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Billing Invoice",
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text(
                "Bill Number: ${bill['billNumber']?.toString() ?? 'Unknown'}",
                style: pw.TextStyle(fontSize: 18)),
            pw.Text(
                "Customer: ${bill['customer']?['name']?.toString() ?? 'Unknown'}",
                style: pw.TextStyle(fontSize: 18)),
            pw.Text("Date: ${bill['date']?.toString() ?? 'Unknown'}",
                style: pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 10),
            pw.Text("Items Purchased:",
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 5),
            if (bill['cart'] is List)
              ...bill['cart'].map<pw.Widget>((item) {
                return pw.Text(
                    "${item['product'] ?? 'Unknown'} - ₹${item['price'] ?? '0.0'}",
                    style: pw.TextStyle(fontSize: 16));
              }).toList(),
            pw.Divider(),
            pw.Text("Total Amount: ₹${bill['totalAmount'] ?? 0}",
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          ],
        ),
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file =
        File("${directory.path}/Bill_${bill['billNumber'] ?? 'Unknown'}.pdf");

    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Bill downloaded: ${file.path}")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Billing History')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: billingHistory.isEmpty
                  ? const Center(child: Text('No billing history available.'))
                  : ListView.builder(
                      itemCount: billingHistory.length,
                      itemBuilder: (context, index) {
                        final bill = billingHistory[index];

                        double totalAmount = double.tryParse(
                                bill['totalAmount']?.toString() ?? '0.0') ??
                            0.0;
                        String billNumber =
                            bill['billNumber']?.toString() ?? 'Unknown';
                        String customerName =
                            bill['customer']?['name']?.toString() ?? 'Unknown';
                        String productName =
                            (bill['cart'] is List && bill['cart'].isNotEmpty)
                                ? bill['cart'][0]['product']?.toString() ??
                                    'No Products'
                                : 'No Products';
                        String dateTime = bill['date']?.toString() ?? 'Unknown';
                        List<String> dateTimeParts = dateTime.split(' ');
                        String date = dateTimeParts.isNotEmpty
                            ? dateTimeParts[0]
                            : 'Unknown';
                        String time = dateTimeParts.length > 1
                            ? dateTimeParts[1]
                            : 'Unknown';

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 4,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16.0),
                            title: Text(
                              "Bill #$billNumber - ₹${totalAmount.toStringAsFixed(2)}",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "Customer: $customerName\n"
                              "Product: $productName\n"
                              "Date: $date\n"
                              "Time: $time",
                              style: const TextStyle(fontSize: 14),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.download,
                                      color: Colors.blue),
                                  onPressed: () => _downloadBill(index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => _deleteBill(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
