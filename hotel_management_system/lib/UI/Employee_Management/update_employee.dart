import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class EmployeeUpdate extends StatefulWidget {
  const EmployeeUpdate({super.key});

  @override
  EmployeeUpdateState createState() => EmployeeUpdateState();
}

class EmployeeUpdateState extends State<EmployeeUpdate> {
  // Sample employee data
  List<Map<String, String>> employees = [
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
  ];

  // Function to delete employee
  void deleteEmployee(int index) {
    setState(() {
      employees.removeAt(index);
    });
  }

  // Function to update employee
  void updateEmployee(int index) {
    TextEditingController nameController =
        TextEditingController(text: employees[index]['name']);
    TextEditingController shiftController =
        TextEditingController(text: employees[index]['shift']);
    TextEditingController roleController =
        TextEditingController(text: employees[index]['role']);
    TextEditingController emailController =
        TextEditingController(text: employees[index]['email']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update Employee"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                TextField(
                  controller: shiftController,
                  decoration: const InputDecoration(labelText: "Shift"),
                ),
                TextField(
                  controller: roleController,
                  decoration: const InputDecoration(labelText: "Role"),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  employees[index] = {
                    'name': nameController.text,
                    'shift': shiftController.text,
                    'role': roleController.text,
                    'email': emailController.text,
                  };
                });
                Navigator.of(context).pop();
              },
              child: const Text("Update"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
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
            // Manage Employee text aligned to the left
            SizedBox(height: screenHeight * 0.07),
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.01,
                horizontal: screenWidth * 0.03,
              ),
              child: FadeInUp(
                duration: const Duration(milliseconds: 1000),
                child: const Align(
                  alignment: Alignment.centerLeft, // Align text to the left
                  child: Text(
                    "Manage Employee Data",
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

            // White box with Card layout
            Center(
              child: Container(
                width: screenWidth * 0.9, // 90% of screen width
                height: screenHeight * 0.75, // 75% of screen height
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(40)),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.02,
                    horizontal: screenWidth * 0.03,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: screenHeight * 0.03),
                        FadeInUp(
                          duration: const Duration(milliseconds: 1200),
                          child: Column(
                            children: List.generate(employees.length, (index) {
                              return Card(
                                margin: EdgeInsets.symmetric(
                                    vertical: screenHeight * 0.015),
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(screenHeight * 0.02),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Name: ${employees[index]['name']}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                          'Shift: ${employees[index]['shift']}'),
                                      Text('Role: ${employees[index]['role']}'),
                                      Text(
                                          'Email: ${employees[index]['email']}'),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                color: Colors.blue),
                                            onPressed: () {
                                              updateEmployee(index);
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () {
                                              deleteEmployee(index);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),
                      ],
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
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: EmployeeUpdate(),
  ));
}
