import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'payment_list_screen.dart';

class PayTrackScreen extends StatefulWidget {
  const PayTrackScreen({super.key});

  @override
  _PayTrackScreenState createState() => _PayTrackScreenState();
}

class _PayTrackScreenState extends State<PayTrackScreen> {
  List<Map<String, dynamic>> payments = [];
  final TextEditingController customerController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  String status = "Pending";

  @override
  void initState() {
    super.initState();
    loadPayments();
  }

  Future<void> loadPayments() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedPayments = prefs.getString('payments');

    if (savedPayments != null && savedPayments.isNotEmpty) {
      setState(() {
        payments = List<Map<String, dynamic>>.from(json.decode(savedPayments));
      });
    }
  }

  Future<void> savePayments() async {
    final prefs = await SharedPreferences.getInstance();
    String jsonData = json.encode(payments);
    await prefs.setString('payments', jsonData);
  }

  void handleAddPayment() async {
    if (customerController.text.isEmpty ||
        mobileController.text.isEmpty ||
        amountController.text.isEmpty ||
        dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields.")),
      );
      return;
    }

    Map<String, dynamic> newPayment = {
      "id": DateTime.now().millisecondsSinceEpoch.toString(),
      "customer": customerController.text,
      "mobile number": mobileController.text,
      "amount": double.tryParse(amountController.text) ?? 0.0,
      "date": dateController.text,
      "status": "Pending",
    };

    setState(() {
      payments.add(newPayment);
    });

    await savePayments(); // ✅ Save before navigating

    customerController.clear();
    mobileController.clear();
    amountController.clear();
    dateController.clear();
    status = "Pending";

    // ✅ Navigate back to the payment list page with updated data
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentListPage(payments: payments),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pay Track',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 5, // Adds shadow effect
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.tealAccent], // Gradient background
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pay Track - Sri Nandhini Marketings',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _buildInputForm(),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: handleAddPayment,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 25),
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5, // Adds button shadow
                      ),
                      child: const Text(
                        'Add Payment',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Form UI Styling
  Widget _buildInputForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTextField(
            controller: customerController,
            label: 'Customer Name',
            icon: Icons.person,
          ),
          const SizedBox(height: 10),
          _buildTextField(
            controller: mobileController,
            label: 'Mobile Number',
            icon: Icons.phone,
            inputType: TextInputType.phone,
          ),
          const SizedBox(height: 10),
          _buildTextField(
            controller: amountController,
            label: 'Amount (in INR)',
            icon: Icons.money,
            inputType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: dateController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Date',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: const Icon(Icons.date_range),
              filled: true,
              fillColor: Colors.grey[200],
            ),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );

              if (pickedDate != null) {
                setState(() {
                  dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
                });
              }
            },
          ),
        ],
      ),
    );
  }

  // Custom Text Field Widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }
}
