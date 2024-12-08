import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String? Ip = dotenv.env['IP'];
final String? Port = dotenv.env['PORT'];

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Colors.blueGrey[900] ?? Colors.blueGrey,
              Colors.blueGrey[700] ?? Colors.blueGrey,
              Colors.blueGrey[400] ?? Colors.blueGrey,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.07),
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.01,
                horizontal: screenWidth * 0.03,
              ),
              child: FadeInUp(
                duration: const Duration(milliseconds: 800),
                child: const Text(
                  "Add Expense",
                  style: TextStyle(color: Colors.white, fontSize: 40),
                ),
              ),
            ),
            Expanded(
              child: FadeInUp(
                duration: const Duration(milliseconds: 1000),
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.03,
                    vertical: screenHeight * 0.02,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                      horizontal: screenWidth * 0.03,
                    ),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FadeInUp(
                              duration: const Duration(milliseconds: 1100),
                              child: buildAmountField(),
                            ),
                            FadeInUp(
                              duration: const Duration(milliseconds: 1200),
                              child: buildDescriptionField(),
                            ),
                            FadeInUp(
                              duration: const Duration(milliseconds: 1300),
                              child: buildDateField(context),
                            ),
                            FadeInUp(
                              duration: const Duration(milliseconds: 1400),
                              child: buildDropdown(),
                            ),
                            SizedBox(height: screenHeight * 0.05),
                            FadeInUp(
                              duration: const Duration(milliseconds: 1500),
                              child: MaterialButton(
                                onPressed: _submitExpense,
                                height: 50,
                                color: Colors.blueGrey[600],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Submit",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Amount Field
  Widget buildAmountField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _amountController,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          labelText: "Enter Amount",
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter an amount";
          }
          if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(value)) {
            return "Enter a valid amount (numbers only)";
          }
          return null;
        },
      ),
    );
  }

  // Description Field
  Widget buildDescriptionField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _descriptionController,
        maxLines: 3,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          labelText: "Enter Description",
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please enter a description";
          }
          return null;
        },
      ),
    );
  }

  // Date Field
  Widget buildDateField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (pickedDate != null) {
            setState(() {
              _selectedDate = pickedDate;
            });
          }
        },
        child: AbsorbPointer(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: "Select Date",
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: const Icon(Icons.calendar_today),
            ),
            controller: TextEditingController(
              text: _selectedDate == null
                  ? ""
                  : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
            ),
            validator: (value) {
              if (_selectedDate == null) {
                return "Please select a date";
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  // Category Dropdown
  Widget buildDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        decoration: InputDecoration(
          labelText: "Select Category",
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        items: ["Bill", "Maintenance", "Furniture", "Others"].map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedCategory = value;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please select a category";
          }
          return null;
        },
      ),
    );
  }

  // Submit the Expense
  void _submitExpense() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Prepare the data to send to the backend
      final expenseData = {
        'amount': double.tryParse(_amountController.text) ?? 0.0,
        'category': _selectedCategory,
        'description': _descriptionController.text,
        'date': _selectedDate != null
            ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
            : '',
      };

      // Define the URL of your Flask API
      final url = Uri.parse('http://$Ip:$Port/add_expense'); // Update with your actual server URL

      // Send a POST request to the backend
      try {
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: json.encode(expenseData),
        );

        // Check if the request was successful
        if (response.statusCode == 201) {
          // If successful, show a success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Expense added successfully!")),
          );
          // You can also navigate to another screen or clear the form here
        } else {
          // If there's an error, show an error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${response.body}")),
          );
        }
      } catch (error) {
        // Handle any errors (network issues, etc.)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Network error: $error")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please correct the errors")),
      );
    }
  }
}


