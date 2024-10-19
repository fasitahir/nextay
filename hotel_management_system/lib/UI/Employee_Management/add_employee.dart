import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  _AddEmployeeScreenState createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cnicController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  DateTime? selectedDOB; // New field for Date of Birth
  String? selectedDesignation;
  String? selectedShift;

  final List<String> designations = [
    'Manager',
    'Staff',
    'Finance Manager',
    'Chef',
    'Janitor'
  ];
  final List<String> shifts = ['Morning', 'Afternoon', 'Night'];

  void _submitEmployee() async {
    final String firstName = firstNameController.text;
    final String lastName = lastNameController.text;
    final String email = emailController.text;
    final String cnic = cnicController.text;
    final String phone = phoneController.text;
    final String salary = salaryController.text;
    final String username = usernameController.text;
    final String password = passwordController.text;

    if (firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        email.isNotEmpty &&
        cnic.isNotEmpty &&
        phone.isNotEmpty &&
        salary.isNotEmpty &&
        username.isNotEmpty &&
        password.isNotEmpty &&
        selectedDOB != null && // Check if DOB is selected
        selectedDesignation != null &&
        selectedShift != null) {
      final response = await http.post(
        Uri.parse('http://192.168.10.28:5000/employee'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'cnic': cnic,
          'phone_number': phone,
          'salary': salary,
          'username': username,
          'password': password,
          'dob': selectedDOB!.toIso8601String(), // Add DOB
          'designation': selectedDesignation,
          'shift': selectedShift,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employee added successfully!')),
        );
        // Clear the form
        firstNameController.clear();
        lastNameController.clear();
        emailController.clear();
        cnicController.clear();
        phoneController.clear();
        salaryController.clear();
        usernameController.clear();
        passwordController.clear();
        setState(() {
          selectedDOB = null;
          selectedDesignation = null;
          selectedShift = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: ${jsonDecode(response.body)['error']}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields correctly.')),
      );
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: screenHeight * 0.07),
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.01,
                horizontal: screenWidth * 0.03,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FadeInUp(
                    duration: const Duration(milliseconds: 1000),
                    child: const Text(
                      "Add Employee's Information",
                      style: TextStyle(color: Colors.white, fontSize: 40),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                ],
              ),
            ),
            Expanded(
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
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: screenHeight * 0.03),
                        FadeInUp(
                          duration: const Duration(milliseconds: 1400),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Colors.blueGrey[200] ?? Colors.blueGrey,
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              children: <Widget>[
                                buildTextField(
                                    firstNameController, "First Name"),
                                buildTextField(lastNameController, "Last Name"),
                                buildTextField(emailController, "Email"),
                                buildTextField(cnicController, "CNIC"),
                                buildTextField(phoneController, "Phone Number"),
                                buildTextField(salaryController, "Salary"),
                                buildTextField(usernameController, "Username"),
                                buildTextField(passwordController, "Password",
                                    obscureText: true),
                                buildDateOfBirthField(
                                    context), // Date of Birth field
                                buildDropdown(
                                    "Select Designation", designations,
                                    (value) {
                                  setState(() {
                                    selectedDesignation = value;
                                  });
                                }, selectedDesignation),
                                buildDropdown("Select Shift", shifts, (value) {
                                  setState(() {
                                    selectedShift = value;
                                  });
                                }, selectedShift),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.05),
                        FadeInUp(
                          duration: const Duration(milliseconds: 1600),
                          child: MaterialButton(
                            onPressed: _submitEmployee,
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
            )
          ],
        ),
      ),
    );
  }

  // Build Text Field Widget
  Widget buildTextField(TextEditingController controller, String hintText,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: hintText,
          labelStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // Build Dropdown Widget
  Widget buildDropdown(String hint, List<String> items,
      ValueChanged<String?> onChanged, String? selectedItem) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: hint,
          labelStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
        ),
        value: selectedItem,
        onChanged: onChanged,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
      ),
    );
  }

  // Build Date of Birth Field
  Widget buildDateOfBirthField(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDOB ?? DateTime.now(),
          firstDate: DateTime(1900), // Set a realistic starting point
          lastDate: DateTime.now(),
        );

        if (picked != null && picked != selectedDOB) {
          setState(() {
            selectedDOB = picked;
          });
        }
      },
      child: AbsorbPointer(
        child: TextField(
          controller: TextEditingController(
            text: selectedDOB != null
                ? "${selectedDOB!.day}/${selectedDOB!.month}/${selectedDOB!.year}"
                : "",
          ),
          decoration: InputDecoration(
            labelText: "Date of Birth",
            labelStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}
