import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class ViewSalaryForEmployee extends StatefulWidget {
  final Employee employee;

  const ViewSalaryForEmployee({super.key, required this.employee});

  @override
  _ViewSalaryForEmployeeState createState() => _ViewSalaryForEmployeeState();
}

class _ViewSalaryForEmployeeState extends State<ViewSalaryForEmployee> {
  // Simulated salary data for the employee
  final List<Map<String, dynamic>> salaryRecords = List.generate(
    10,
    (index) => {
      'date': DateTime.now().subtract(Duration(days: index * 30)),
      'amount': (2000 + index * 100).toDouble(), // Sample salary amounts
      'incentive': (index * 50).toDouble(), // Sample incentive amounts
    },
  );

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
                  "Your Salary",
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
                  child: ListView.builder(
                    itemCount: salaryRecords.length,
                    itemBuilder: (context, index) {
                      final record = salaryRecords[index];
                      final date = DateFormat('yyyy-MM').format(record['date']);
                      final amount = record['amount'].toStringAsFixed(2);
                      final incentive = record['incentive'].toStringAsFixed(2);

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.money,
                            color: Colors.green[700],
                          ),
                          title: Text("Month: $date"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Salary: \$ $amount"),
                              Text("Incentive: \$ $incentive"),
                              Text(
                                  "Designation: ${widget.employee.designation}"),
                            ],
                          ),
                        ),
                      );
                    },
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
  final double salary;

  Employee({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.designation,
    required this.salary,
  });
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ViewSalaryForEmployee(
      employee: Employee(
        id: 1,
        firstName: 'John',
        lastName: 'Doe',
        designation: 'Chef',
        salary: 3000,
      ),
    ),
  ));
}
