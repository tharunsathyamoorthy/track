import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:billing_app_flutter/screens/billing_history_screen.dart'
    as history;

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  _BillingScreenState createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  String? selectedType;
  String? selectedRepeat;

  final List<String> types = ["Bills", "Groceries", "Rent", "Subscription"];
  final List<String> repeats = ["Daily", "Weekly", "Monthly", "Yearly"];

  final String apiUrl = "http://10.0.2.2:5000"; // Localhost for emulator

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _selectTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  Future<void> _saveBillingData() async {
    String customerName = titleController.text.trim();
    String amountText = amountController.text.trim();
    String notes = notesController.text.trim();

    if (customerName.isEmpty || amountText.isEmpty) {
      _showSnackBar("❌ Please enter Customer Name and Amount");
      return;
    }

    double? amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showSnackBar("❌ Please enter a valid amount");
      return;
    }

    Map<String, dynamic> billData = {
      "customerName": customerName,
      "amount": amount,
      "notes": notes,
      "type": selectedType ?? "Other",
      "repeat": selectedRepeat ?? "None",
      "date": DateFormat('yyyy-MM-dd').format(selectedDate),
      "time": "${selectedTime.hour}:${selectedTime.minute}",
    };

    await _saveBillingDataLocally(billData);

    try {
      final response = await http.post(
        Uri.parse("$apiUrl/api/add-bill"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(billData),
      );

      if (response.statusCode == 201) {
        _showSnackBar("✅ Billing data saved successfully");
        _clearFields();
      } else {
        var responseData = jsonDecode(response.body);
        _showSnackBar(
            "❌ Failed: ${responseData['message'] ?? 'Unknown error'}");
      }
    } catch (e) {
      _showSnackBar("❌ Error saving billing data: $e");
    }
  }

  Future<void> _saveBillingDataLocally(Map<String, dynamic> billData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> billingHistory = prefs.getStringList('billingHistory') ?? [];
    billingHistory.add(jsonEncode(billData));
    await prefs.setStringList('billingHistory', billingHistory);
  }

  void _viewBillingHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => const history.BillingHistoryScreen()),
    );
  }

  void _showQRCode() {
    String customerName = titleController.text.trim();
    String amount = amountController.text.trim();

    if (customerName.isEmpty || amount.isEmpty) {
      _showSnackBar("❌ Please enter Customer Name and Amount");
      return;
    }

    String upiData =
        "upi://pay?pa=tharunsathy@okhdfcbank&pn=$customerName&am=$amount&cu=INR";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Scan to Pay'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(
                data: upiData,
                version: QrVersions.auto,
                size: 200.0,
              ),
              const SizedBox(height: 10),
              Text("₹$amount",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const Text("Scan the QR Code to proceed with payment."),
              const SizedBox(height: 10),
              const Text("UPI ID: tharunsathy@okhdfcbank"),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close")),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _clearFields() {
    setState(() {
      titleController.clear();
      amountController.clear();
      notesController.clear();
      selectedType = null;
      selectedRepeat = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(titleController, "Customer Name"),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildIconButton(Icons.calendar_today, _selectDate),
                  Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                  const SizedBox(width: 16),
                  _buildIconButton(Icons.access_time, _selectTime),
                  Text("${selectedTime.hour}:${selectedTime.minute}"),
                ],
              ),
              const SizedBox(height: 20),
              _buildDropdown("Type", selectedType, types,
                  (value) => setState(() => selectedType = value)),
              const SizedBox(height: 20),
              _buildDropdown("Repeat", selectedRepeat, repeats,
                  (value) => setState(() => selectedRepeat = value)),
              const SizedBox(height: 20),
              _buildTextField(amountController, "Amount (INR)", isNumber: true),
              const SizedBox(height: 20),
              _buildTextField(notesController, "Notes"),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionButton(
                      "Generate Bill", Colors.green, _saveBillingData),
                  const SizedBox(width: 10),
                  _buildActionButton(
                      "Continue Payment", Colors.blue, _showQRCode),
                  const SizedBox(width: 10),
                  _buildActionButton("View Billing History", Colors.orange,
                      _viewBillingHistory),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration:
          InputDecoration(labelText: hint, border: OutlineInputBorder()),
    );
  }
}

Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
  return IconButton(icon: Icon(icon, color: Colors.teal), onPressed: onPressed);
}

Widget _buildActionButton(String label, Color color, VoidCallback onPressed) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(backgroundColor: color),
    onPressed: onPressed,
    child: Text(label, style: const TextStyle(color: Colors.white)),
  );
}

Widget _buildDropdown(String label, String? value, List<String> items,
    ValueChanged<String?> onChanged) {
  return DropdownButtonFormField<String>(
    value: value,
    decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
    items:
        items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
    onChanged: onChanged,
  );
}
