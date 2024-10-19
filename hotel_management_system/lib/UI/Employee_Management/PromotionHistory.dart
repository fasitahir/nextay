import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EmployeeManagementHistory extends StatefulWidget {
  final List<Employee> employees;

  const EmployeeManagementHistory({super.key, required this.employees});

  @override
  _EmployeeManagementState createState() => _EmployeeManagementState();
}

class _EmployeeManagementState extends State<EmployeeManagementHistory> {
  void _viewPromotionHistory(Employee employee) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PromotionHistoryPage(employee: employee),
      ),
    );
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
                  "Promotion History",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Expanded(
              child: Container(
                width: screenWidth * 0.9,
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
                    itemCount: widget.employees.length,
                    itemBuilder: (context, index) {
                      final employee = widget.employees[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${employee.firstName} ${employee.lastName}",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text("Designation: ${employee.designation}"),
                              Text(
                                  "Salary: \$${employee.salary.toStringAsFixed(2)}"),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () =>
                                    _viewPromotionHistory(employee),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueGrey[600],
                                ),
                                child: const Text(
                                  "View Promotion History",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
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

class PromotionHistoryPage extends StatelessWidget {
  final Employee employee;

  const PromotionHistoryPage({super.key, required this.employee});

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
                  "Promotion History",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Expanded(
              child: Container(
                width: screenWidth * 0.9,
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
                    itemCount: employee.promotionHistory.length,
                    itemBuilder: (context, index) {
                      final promotion = employee.promotionHistory[index];
                      return ListTile(
                        title: Text(
                          "Promotion to ${promotion.newDesignation}",
                          style: const TextStyle(fontSize: 18),
                        ),
                        subtitle: Text(
                          "On ${DateFormat.yMMMd().format(promotion.date)} \n"
                          "Previous Designation: ${promotion.oldDesignation}\n"
                          "New Salary: \$${promotion.newSalary.toStringAsFixed(2)}",
                        ),
                        isThreeLine: true,
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
  String firstName;
  String lastName;
  String designation;
  double salary;
  List<Promotion> promotionHistory;

  Employee({
    required this.firstName,
    required this.lastName,
    required this.designation,
    required this.salary,
    List<Promotion>? promotionHistory,
  }) : promotionHistory = promotionHistory ?? [];
}

class Promotion {
  DateTime date;
  String oldDesignation;
  String newDesignation;
  double newSalary;

  Promotion({
    required this.date,
    required this.oldDesignation,
    required this.newDesignation,
    required this.newSalary,
  });
}

