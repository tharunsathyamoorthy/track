import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BillingHistoryScreen extends StatefulWidget {
  const BillingHistoryScreen({super.key});

  @override
  _BillingHistoryScreenState createState() => _BillingHistoryScreenState();
}

class _BillingHistoryScreenState extends State<BillingHistoryScreen> {
  final String apiBaseUrl = "http://localhost:5000/api"; // Node.js API URL
  late Future<List<Map<String, dynamic>>> _billingHistoryFuture;

  @override
  void initState() {
    super.initState();
    _billingHistoryFuture = fetchBillingHistory();
  }

  Future<List<Map<String, dynamic>>> fetchBillingHistory() async {
    try {
      final response = await http.get(Uri.parse("$apiBaseUrl/billing-history"));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      return Future.error("Failed to load billing history: $e");
    }
  }

  Future<void> deleteBill(String billId) async {
    try {
      final response =
          await http.delete(Uri.parse("$apiBaseUrl/delete-bill/$billId"));

      if (response.statusCode == 200) {
        setState(() {
          _billingHistoryFuture = fetchBillingHistory();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Bill deleted successfully")),
        );
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error deleting bill: $e")),
      );
    }
  }

  Future<String> getDownloadPath() async {
    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }
    return directory?.path ?? "/storage/emulated/0/Download";
  }

  Future<void> downloadBill(Map<String, dynamic> bill) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Billing Invoice",
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text("Bill ID: ${bill['_id']['\$oid']}",
                  style: pw.TextStyle(fontSize: 18)),
              pw.Text("Customer: ${bill['customerName'] ?? 'Unknown'}",
                  style: pw.TextStyle(fontSize: 18)),
              pw.Text("Date: ${bill['date'] ?? 'Unknown'}",
                  style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.Text("Total Amount: ₹${bill['amount'] ?? '0.00'}",
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ),
      );

      final path = await getDownloadPath();
      final file = File("$path/Bill_${bill['_id']['\$oid']}.pdf");

      await file.writeAsBytes(await pdf.save());
      await OpenFile.open(file.path);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Bill downloaded: ${file.path}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error downloading bill: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Billing History')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _billingHistoryFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                  child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No billing history available.'));
            }

            final billingHistory = snapshot.data!;
            return ListView.builder(
              itemCount: billingHistory.length,
              itemBuilder: (context, index) {
                final bill = billingHistory[index];
                double totalAmount =
                    double.tryParse(bill['amount']?.toString() ?? '0') ?? 0.0;
                String customerName = bill['customerName'] ?? 'Unknown';
                String date = bill['date'] ?? 'Unknown';
                String billId = bill['_id']['\$oid']; // Correct ID parsing

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(
                      "Bill #$billId - ₹${totalAmount.toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Customer: $customerName\nDate: $date",
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.download, color: Colors.blue),
                          onPressed: () => downloadBill(bill),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteBill(billId),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
