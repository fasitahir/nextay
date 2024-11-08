import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // For date formatting
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String? Ip = dotenv.env['IP'];
final String? Port = dotenv.env['PORT'];

class PaySalaryForManager extends StatefulWidget {
  const PaySalaryForManager({super.key});

  @override
  _PaySalaryForManagerState createState() => _PaySalaryForManagerState();
}

class _PaySalaryForManagerState extends State<PaySalaryForManager> {
  DateTime selectedDate = DateTime.now();
  List<Employee> employees = [];

  @override
  void initState() {
    super.initState();
    fetchEmployees().then((employeeList) {
      setState(() {
        employees = employeeList;
      });
    });
  }

  // Fetch employee data from the API
  Future<List<Employee>> fetchEmployees() async {
    final response =
        await http.get(Uri.parse('http://$Ip:$Port/employee_data'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data
          .map((employeeJson) => Employee.fromJson(employeeJson))
          .toList();
    } else {
      throw Exception('Failed to load employee data');
    }
  }

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

  // Function to show a dialog for entering bonus and incentive description
  void _showBonusDialog(BuildContext context, int index) {
    final TextEditingController bonusController = TextEditingController();
    final TextEditingController descriptionController =
        TextEditingController(); // New controller for description

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Bonus Amount and Description'),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Adjusts dialog size to content
            children: [
              TextField(
                controller: bonusController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Bonus Amount'),
              ),
              TextField(
                controller:
                    descriptionController, // New TextField for description
                decoration:
                    const InputDecoration(labelText: 'Incentive Description'),
              ),
            ],
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
                String description = descriptionController.text;

                if (bonus != null && description.isNotEmpty) {
                  setState(() {
                    employees[index]
                        .addBonus(bonus, description); // Pass description
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
                        child: employees.isEmpty
                            ? Center(
                                child:
                                    CircularProgressIndicator()) // Show loading spinner
                            : ListView.builder(
                                itemCount: employees.length,
                                itemBuilder: (context, index) {
                                  final employee = employees[index];
                                  final salary =
                                      employee.salary.toStringAsFixed(2);

                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    color: employee.paid == 23
                                        ? Colors.green[100]
                                        : Colors
                                            .white, // Change color based on payment status
                                    child: ListTile(
                                      leading: Icon(
                                        Icons.person,
                                        color: Colors.blueGrey[700],
                                      ),
                                      title: Text(
                                          '${employee.firstName} ${employee.lastName}'),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Salary: \$ $salary'),
                                          Text(
                                              'Designation: ${employee.position}'),
                                          if (employee.incentiveDescription !=
                                              null) // Check if there is a description
                                            Text(
                                                'Incentive: ${employee.incentiveDescription}',
                                                style: TextStyle(
                                                    color: Colors.green)),
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ElevatedButton(
                                            onPressed: employee.paid == 23
                                                ? null // Disable button if already paid
                                                : () async {
                                                    // Make the POST request to the API
                                                    final response =
                                                        await http.post(
                                                      Uri.parse(
                                                          'http://$Ip:$Port/pay_salary'),
                                                      headers: <String, String>{
                                                        'Content-Type':
                                                            'application/json; charset=UTF-8',
                                                      },
                                                      body: jsonEncode(<String,
                                                          dynamic>{
                                                        'employee_id':
                                                            employee.id,
                                                        'salary':
                                                            employee.salary,
                                                        'incentive': employee
                                                                    .incentiveDescription !=
                                                                null
                                                            ? employee.salary -
                                                                employee
                                                                    .baseSalary
                                                            : null,
                                                        'incentive_description':
                                                            employee
                                                                .incentiveDescription,
                                                        'pay_date': DateFormat(
                                                                'yyyy-MM-dd')
                                                            .format(
                                                                selectedDate), // Send selected date
                                                        'paid_by':
                                                            'Manager' // Assuming manager is paying, this can be dynamic
                                                      }),
                                                    );

                                                    if (response.statusCode ==
                                                        201) {
                                                      setState(() {
                                                        employee.paid =
                                                            23; // Update the UI to reflect the payment status
                                                      });
                                                    } else {
                                                      // Handle error
                                                      print(
                                                          'Failed to pay salary: ${response.body}');
                                                    }
                                                  },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  employee.paid == 23
                                                      ? Colors.green[200]
                                                      : Colors.blueGrey[600],
                                            ),
                                            child: Text(
                                              employee.paid == 23
                                                  ? 'Paid'
                                                  : 'Pay',
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            onPressed: employee.paid == 23
                                                ? null // Disable button if already paid
                                                : () => _showBonusDialog(
                                                    context,
                                                    index), // Show bonus dialog
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.blueGrey[600],
                                            ),
                                            child: const Text('Bonus',
                                                style: TextStyle(
                                                    color: Colors.white)),
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

// Employee class with factory constructor for API data
class Employee {
  final int? id;
  final String? firstName;
  final String? lastName;
  final String? contact;
  final String? position; // Assuming this is the designation
  double salary;
  int? paid; // Keep it as an integer
  String? incentiveDescription; // Add this field for incentive description
  double baseSalary; // New field for the base salary

  Employee({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.contact,
    required this.position,
    required this.salary,
    required this.paid,
    required this.baseSalary,
    this.incentiveDescription,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      contact: json['contact'],
      position: json['Position'],
      salary: json['salary'],
      paid: json['is_paid'],
      baseSalary: json['salary'], // Assuming base salary is in the API
    );
  }

  // Function to add bonus to the employee's salary
  void addBonus(double bonus, String description) {
    salary += bonus;
    incentiveDescription = description;
  }
}
