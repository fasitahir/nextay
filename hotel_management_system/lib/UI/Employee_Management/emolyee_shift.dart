import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class EmployeeShift extends StatefulWidget {
  const EmployeeShift({super.key});

  @override
  EmployeeShiftState createState() => EmployeeShiftState();
}

class EmployeeShiftState extends State<EmployeeShift> {
  String selectedShift = 'Morning'; // Default shift selection

  // Sample employee data
  final List<Map<String, String>> employees = [
    {
      'name': 'John Doe',
      'shift': 'Morning',
      'role': 'Manager',
      'email': 'john.doe@example.com',
    },
    {
      'name': 'Jane Smith',
      'shift': 'Afternoon',
      'role': 'Chef',
      'email': 'jane.smith@example.com',
    },
    {
      'name': 'Mark Lee',
      'shift': 'Night',
      'role': 'Receptionist',
      'email': 'mark.lee@example.com',
    },
    {
      'name': 'Alice Brown',
      'shift': 'Morning',
      'role': 'Housekeeping',
      'email': 'alice.brown@example.com',
    },
    {
      'name': 'David Green',
      'shift': 'Afternoon',
      'role': 'Security',
      'email': 'david.green@example.com',
    },
    {
      'name': 'Fasi Tahir',
      'shift': 'Morning',
      'role': 'Manager',
      'email': 'fasitahir2019@gmail.com',
    },
    {
      'name': 'Laiba Khan',
      'shift': 'Morning',
      'role': 'Manager',
      'email': 'lk420@gmail.com',
    },
  ];

  // Method to filter employees based on selected shift
  List<Map<String, String>> getFilteredEmployees() {
    return employees.where((employee) {
      return employee['shift'] == selectedShift;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWeb = screenWidth > 800; // Set threshold for large screens

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
              child: FadeInUp(
                duration: const Duration(milliseconds: 1000),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Manage Employee Shifts",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.01,
                  horizontal: screenWidth * 0.03,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.02,
                    horizontal: screenWidth * 0.03,
                  ),
                  child: Column(
                    children: [
                      FadeInUp(
                        duration: const Duration(milliseconds: 1200),
                        child: buildShiftDropdown(screenHeight),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Expanded(
                        child: FadeInUp(
                          duration: const Duration(milliseconds: 1400),
                          child: SingleChildScrollView(
                            child: isWeb
                                ? Wrap(
                                    spacing: screenWidth *
                                        0.02, // Spacing between cards
                                    runSpacing:
                                        screenHeight * 0.02, // Vertical spacing
                                    children:
                                        getFilteredEmployees().map((employee) {
                                      return buildEmployeeCard(
                                          employee,
                                          screenHeight,
                                          screenWidth *
                                              0.3); // 30% width for web
                                    }).toList(),
                                  )
                                : Column(
                                    children:
                                        getFilteredEmployees().map((employee) {
                                      return buildEmployeeCard(
                                          employee,
                                          screenHeight,
                                          screenWidth); // Full width for mobile
                                    }).toList(),
                                  ),
                          ),
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

  // Build Shift Dropdown Widget
  Widget buildShiftDropdown(double screenHeight) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey[200] ?? Colors.blueGrey,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        value: selectedShift,
        hint: const Text("Select Shift", style: TextStyle(color: Colors.grey)),
        items: ['Morning', 'Afternoon', 'Night'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            selectedShift = newValue!;
          });
        },
      ),
    );
  }

  // Build Employee Card
  Widget buildEmployeeCard(
      Map<String, String> employee, double screenHeight, double cardWidth) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: cardWidth,
        padding: EdgeInsets.all(screenHeight * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: ${employee['name']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Shift: ${employee['shift']}'),
            Text('Role: ${employee['role']}'),
            Text('Email: ${employee['email']}'),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: EmployeeShift(),
  ));
}
