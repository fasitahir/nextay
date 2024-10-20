import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmployeeUpdate extends StatefulWidget {
  const EmployeeUpdate({super.key});

  @override
  EmployeeUpdateState createState() => EmployeeUpdateState();
}

class EmployeeUpdateState extends State<EmployeeUpdate> {
  List<Map<String, dynamic>> employees = [];

  @override
  void initState() {
    super.initState();
    fetchEmployees(); // Fetch employee data when the widget is initialized
  }

  // Fetch employee data from the API
  Future<void> fetchEmployees() async {
    try {
      final response = await http.get(Uri.parse(
          'http://192.168.100.19:5000/employees')); // Update with your API URL

      if (response.statusCode == 200) {
        final List<dynamic> employeeData = json.decode(response.body);
        setState(() {
          employees = employeeData
              .map((emp) => {
                    'id': emp['id'],
                    'name':
                        '${emp['first_name']} ${emp['last_name']}', // Combine first and last names
                    'shift': emp['shift'],
                    'role': emp['role'],
                    'email': emp['email'],
                  })
              .toList();
        });
      } else {
        throw Exception('Failed to load employees');
      }
    } catch (e) {
      // Handle the error
      print('Error fetching employees: $e');
    }
  }

  // Function to delete employee
  Future<void> deleteEmployee(int index) async {
    try {
      final employeeId = employees[index]['id'];
      final response = await http.delete(
        Uri.parse('http://192.168.100.19:5000/employee/$employeeId'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        setState(() {
          employees.removeAt(index); // Remove employee from the UI
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Employee deleted successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to delete employee: ${response.body}')),
        );
      }
    } catch (e) {
      print('Error deleting employee: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting employee: $e')),
      );
    }
  }

  // Function to update employee
  Future<void> updateEmployee(int index) async {
    TextEditingController nameController =
        TextEditingController(text: employees[index]['name']);
    TextEditingController shiftController =
        TextEditingController(text: employees[index]['shift']);
    TextEditingController roleController =
        TextEditingController(text: employees[index]['role']);
    TextEditingController emailController =
        TextEditingController(text: employees[index]['email']);
    TextEditingController usernameController =
        TextEditingController(text: employees[index]['username'] ?? '');
    TextEditingController passwordController = TextEditingController();

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
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: "Username"),
                ),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: "Password"),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Call the API to update the employee
                final response = await http.put(
                  Uri.parse(
                      'http://192.168.10.28:5000/employee/${employees[index]['id']}'), // Use your API URL
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode({
                    'first_name': nameController.text.split(' ')[0],
                    'last_name':
                        nameController.text.split(' ').sublist(1).join(' '),
                    'email': emailController.text,
                    'shift': shiftController.text,
                    'role': roleController.text,
                    'username': usernameController.text,
                    'password': passwordController.text, // New password field
                  }),
                );

                if (response.statusCode == 200) {
                  setState(() {
                    employees[index] = {
                      'id': employees[index]['id'], // Preserve the ID
                      'name': nameController.text,
                      'shift': shiftController.text,
                      'role': roleController.text,
                      'email': emailController.text,
                      'username': usernameController.text,
                    };
                  });
                  Navigator.of(context).pop();
                } else {
                  // Handle the error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Failed to update employee: ${response.body}')),
                  );
                }
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
            Center(
              child: Container(
                width: screenWidth * 0.9,
                height: screenHeight * 0.75,
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
