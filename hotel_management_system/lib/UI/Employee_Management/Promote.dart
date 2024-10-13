import 'package:flutter/material.dart';

class EmployeeManagement extends StatefulWidget {
  final List<Employee> employees;

  const EmployeeManagement({super.key, required this.employees});

  @override
  _EmployeeManagementState createState() => _EmployeeManagementState();
}

class _EmployeeManagementState extends State<EmployeeManagement> {
  void _promoteEmployee(Employee employee) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PromoteEmployee(employee: employee);
      },
    ).then((_) {
      setState(() {}); // Refresh the UI after promotion
    });
  }

  void _changeSalary(Employee employee) {
    TextEditingController salaryController =
        TextEditingController(text: employee.salary.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Salary for ${employee.firstName}'),
          content: TextField(
            controller: salaryController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "Enter new salary"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  double newSalary =
                      double.tryParse(salaryController.text.trim()) ??
                          employee.salary;
                  employee.salary = newSalary;
                });
                Navigator.of(context).pop();
              },
              child: const Text("Save"),
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
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Employee Management",
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => _promoteEmployee(employee),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueGrey[600],
                                    ),
                                    child: const Text(
                                      "Promote",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => _changeSalary(employee),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueGrey[600],
                                    ),
                                    child: const Text(
                                      "Change Salary",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
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

class PromoteEmployee extends StatefulWidget {
  final Employee employee;

  const PromoteEmployee({super.key, required this.employee});

  @override
  _PromoteEmployeeState createState() => _PromoteEmployeeState();
}

class _PromoteEmployeeState extends State<PromoteEmployee> {
  String? selectedDesignation;
  final TextEditingController salaryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedDesignation = widget.employee.designation;
    salaryController.text = widget.employee.salary.toString();
  }

  @override
  void dispose() {
    salaryController.dispose();
    super.dispose();
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
                  "Promote Employee",
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
                    vertical: screenHeight * 0.03,
                    horizontal: screenWidth * 0.03,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Employee: ${widget.employee.firstName} ${widget.employee.lastName}",
                        style: const TextStyle(fontSize: 20),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        "Select Designation:",
                        style: const TextStyle(fontSize: 18),
                      ),
                      DropdownButton<String>(
                        value: selectedDesignation,
                        items: ['Chef', 'Janitor', 'Staff', 'Manager']
                            .map((designation) {
                          return DropdownMenuItem<String>(
                            value: designation,
                            child: Text(designation),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedDesignation = newValue;
                          });
                        },
                        isExpanded: true,
                        style:
                            const TextStyle(fontSize: 18, color: Colors.black),
                        underline: Container(
                          height: 2,
                          color: Colors.blueGrey[700],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        "Enter New Salary:",
                        style: const TextStyle(fontSize: 18),
                      ),
                      TextField(
                        controller: salaryController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Enter salary in USD",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.04),
                      Center(
                        child: MaterialButton(
                          onPressed: () {
                            double newSalary =
                                double.tryParse(salaryController.text.trim()) ??
                                    widget.employee.salary;

                            setState(() {
                              widget.employee.salary = newSalary;
                              widget.employee.designation =
                                  selectedDesignation!;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    "${widget.employee.firstName} has been promoted to $selectedDesignation with a salary of \$${newSalary.toStringAsFixed(2)}"),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.of(context).pop();
                          },
                          height: 50,
                          color: Colors.blueGrey[600],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Center(
                            child: Text(
                              "Promote",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
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
  String designation;
  double salary;

  Employee({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.designation,
    required this.salary,
  });
}

