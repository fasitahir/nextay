import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String? Ip = dotenv.env['IP'];
final String? Port = dotenv.env['PORT'];

class ViewExpenses extends StatefulWidget {
  const ViewExpenses({super.key});

  @override
  _ViewExpensesState createState() => _ViewExpensesState();
}

class _ViewExpensesState extends State<ViewExpenses> {
  List<Expense> expenses = [];
  bool isLoading = false; // To show loading indicator

  @override
  void initState() {
    super.initState();
    _fetchExpenses(); // Fetch data when the screen loads
  }

  // Function to fetch all expenses (no date filtering)
Future<List<Expense>> fetchExpenses() async {
  String url = 'http://$Ip:$Port/get_expenses'; // Update with your API endpoint

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    // Log the response body to inspect its structure
    print('Response body: ${response.body}');
    
    // Check if the response is a Map or List
    var data = json.decode(response.body);

    if (data is List) {
      // If it's a List, directly map it to List<Expense>
      return data.map((item) => Expense.fromJson(item)).toList();
    } else if (data is Map) {
      // If it's a Map, check if it contains the list in a key
      // For example: { "expenses": [list_of_expenses] }
      var expensesList = data['expenses'] as List;
      return expensesList.map((item) => Expense.fromJson(item)).toList();
    } else {
      throw Exception('Unexpected data format');
    }
  } else {
    throw Exception('Failed to load expense data');
  }
}

  // Fetch all expenses
  void _fetchExpenses() async {
    setState(() {
      isLoading = true; // Show loading indicator
    });

    try {
      List<Expense> fetchedExpenses = await fetchExpenses();
      setState(() {
        expenses = fetchedExpenses;
      });
    } catch (e) {
      print('Error fetching expense data: $e');
      // Optionally show a Snackbar or AlertDialog for errors
    } finally {
      setState(() {
        isLoading = false; // Hide loading indicator
      });
    }
  }

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
          children: [
            SizedBox(height: screenHeight * 0.07),
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.01,
                horizontal: screenWidth * 0.03,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "View Expenses",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),

            // White box with Card layout
            Expanded(
              child: Container(
                width: screenWidth * 0.9, // 90% of screen width
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.02,
                    horizontal: screenWidth * 0.03,
                  ),
                  child: Column(
                    children: [
                      // Show Title Only
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        'All Expenses',
                        style: const TextStyle(fontSize: 20),
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      // If loading, show a CircularProgressIndicator
                      if (isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (expenses.isEmpty)
                        const Center(child: Text('No expenses found'))
                      else
                        Expanded(
                          child: ListView.builder(
                            itemCount: expenses.length,
                            itemBuilder: (context, index) {
                              final expense = expenses[index];
                              final amount = expense.amount?.toStringAsFixed(2);
                              final date = expense.date;
                              final category = expense.category;

                              return Card(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 10),
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0), // Added padding for better spacing
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.money,
                                      color: Colors.blueGrey[700],
                                    ),
                                    title: Text(
                                      'Expense: \$ $amount',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 5),
                                        Text('Category: $category'),
                                        SizedBox(height: 5),
                                        Text('Date: $date'),
                                        SizedBox(height: 5),
                                        Text('Notes: ${expense.notes}'),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Expense {
  final int expenseId;
  final String date;
  final String category;
  final double? amount;
  final String notes;

  Expense({
    required this.expenseId,
    required this.date,
    required this.category,
    required this.amount,
    required this.notes,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      expenseId: json['ExpenseID'],
      date: json['Date'],
      category: json['Category'],
      amount: json['Amount'],
      notes: json['Notes'],
    );
  }
}
