import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class PaySalaryForManager extends StatefulWidget {
  const PaySalaryForManager({super.key});

  @override
  _PaySalaryForManagerState createState() => _PaySalaryForManagerState();
}

class _PaySalaryForManagerState extends State<PaySalaryForManager> {
  DateTime selectedDate = DateTime.now();
  List<Employee> employees = List.generate(
    10,
    (index) => Employee(
      id: index,
      firstName: 'Employee',
      lastName: '${index + 1}',
      designation: ['Chef', 'Janitor', 'Staff', 'Manager'][index % 4],
      salary: 2000 + index * 100, // Example salaries
      incentive: index * 50.0, // Example incentive
    ),
  );

  // Function to select a date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Function to show a dialog for entering bonus
  void _showBonusDialog(BuildContext context, int index) {
    final TextEditingController bonusController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Bonus Amount'),
          content: TextField(
            controller: bonusController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Bonus Amount'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                double? bonus = double.tryParse(bonusController.text);
                if (bonus != null) {
                  setState(() {
                    employees[index].addBonus(bonus); // Add bonus to incentive
                  });
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
              child: const Text('Add Bonus'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yyyy-MM').format(selectedDate);
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
                  "Manage Salaries",
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Date: $formattedDate',
                            style: const TextStyle(fontSize: 20),
                          ),
                          ElevatedButton(
                            onPressed: () => _selectDate(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey[600],
                            ),
                            child: const Text('Pick a Date',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Expanded(
                        child: ListView.builder(
                          itemCount: employees.length,
                          itemBuilder: (context, index) {
                            final employee = employees[index];
                            final salary = employee.salary.toStringAsFixed(2);
                            final incentive =
                                employee.incentive.toStringAsFixed(2);

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              color: employee.paid ? Colors.green[100] : Colors.white, // Change color based on payment status
                              child: ListTile(
                                leading: Icon(
                                  Icons.person,
                                  color: Colors.blueGrey[700],
                                ),
                                title: Text(
                                    '${employee.firstName} ${employee.lastName}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Salary: \$ $salary'),
                                    Text('Incentive: \$ $incentive'),
                                    Text(
                                        'Designation: ${employee.designation}'),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ElevatedButton(
                                      onPressed: employee.paid
                                          ? null // Disable button if already paid
                                          : () {
                                              setState(() {
                                                employee.paid = true; // Mark as paid
                                              });
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: employee.paid ? Colors.green[200] : Colors.blueGrey[600],
                                      ),
                                      child: Text(employee.paid ? 'Paid' : 'Pay',style: const TextStyle(color: Colors.white)),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: employee.paid
                                          ? null // Disable button only after a bonus has been added
                                          : () => _showBonusDialog(context, index), // Show bonus dialog
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blueGrey[600],
                                      ),
                                      child: const Text('Bonus',style: TextStyle(color: Colors.white)),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Employee {
  final int id;
  final String firstName;
  final String lastName;
  final String designation;
  double salary; // Made salary mutable
  double incentive;
  bool paid; // New property to track payment status

  Employee({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.designation,
    required this.salary,
    required this.incentive,
    this.paid = false, // Default to unpaid
  });

  // Method to update salary with bonus
  void addBonus(double bonus) {
    incentive += bonus; // Update incentive with bonus
    // The paid flag remains unchanged, allowing for multiple bonuses
  }
}
