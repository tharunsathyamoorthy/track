import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'billing_history_screen.dart';

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

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void _showQRCode() {
    String customerName = titleController.text.trim();
    String amount = amountController.text.trim();

    if (customerName.isEmpty || amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter Customer Name and Amount")),
      );
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
              Text(
                "₹$amount",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Text("Scan the QR Code to proceed with payment."),
              const SizedBox(height: 10),
              const Text("UPI ID: tharunsathy@okhdfcbank"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _generateBill() async {
    String customerName = titleController.text.trim();
    String amount = amountController.text.trim();
    String notes = notesController.text.trim();
    String date = DateFormat('yyyy-MM-dd').format(selectedDate);
    String time = selectedTime.format(context);

    if (customerName.isEmpty || amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    // Generate unique bill number
    String billNumber = DateTime.now().millisecondsSinceEpoch.toString();

    final bill = {
      "billNumber": billNumber,
      "customer": {"name": customerName}, // Fixed customer data structure
      "totalAmount": amount,
      "date": date,
      "time": time,
      "notes": notes,
      "type": selectedType ?? "Not specified",
      "repeat": selectedRepeat ?? "Not specified",
      "cart": [
        {"product": "Sample Product", "price": amount} // Placeholder cart data
      ]
    };

    final prefs = await SharedPreferences.getInstance();
    List<String>? history = prefs.getStringList('billingHistory');
    history = history ?? [];
    history.add(jsonEncode(bill));
    await prefs.setStringList('billingHistory', history);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Bill generated successfully!")),
    );
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
              const Text("Date and Time:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  _buildIconButton(Icons.calendar_today, _selectDate),
                  Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                  const SizedBox(width: 16),
                  _buildIconButton(Icons.access_time, _selectTime),
                  Text(selectedTime.format(context)),
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
                      "Generate Bill", Colors.green, _generateBill),
                  const SizedBox(width: 10),
                  _buildActionButton(
                      "Continue Payment", Colors.blue, _showQRCode),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BillingHistoryScreen()),
                  );
                },
                child: const Text('View Billing History'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildTextField(TextEditingController controller, String label,
    {bool isNumber = false}) {
  return TextField(
    controller: controller,
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
  );
}

Widget _buildDropdown(String label, String? selectedValue, List<String> items,
    ValueChanged<String?> onChanged) {
  return DropdownButtonFormField<String>(
    value: selectedValue,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
    items: items
        .map((item) => DropdownMenuItem(value: item, child: Text(item)))
        .toList(),
    onChanged: onChanged,
  );
}

Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
  return IconButton(
    icon: Icon(icon, color: Colors.blueAccent),
    onPressed: onPressed,
  );
}

Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    ),
    child: Text(text, style: const TextStyle(color: Colors.white)),
  );
}
