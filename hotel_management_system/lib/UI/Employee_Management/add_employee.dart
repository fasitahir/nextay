import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

final String? Ip = dotenv.env['IP'];
final String? Port = dotenv.env['PORT'];

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  _AddEmployeeScreenState createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>(); // Form key for validation
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
    if (_formKey.currentState?.validate() ?? false) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? employeeId = prefs.getInt('employeeId');

      if (employeeId != null) {
        // Call the backend API with the employeeId
        final response = await http.post(
          Uri.parse('http://$Ip:$Port/employee'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            'first_name': firstNameController.text,
            'last_name': lastNameController.text,
            'email': emailController.text,
            'cnic': cnicController.text,
            'phone_number': phoneController.text,
            'salary': salaryController.text,
            'username': usernameController.text,
            'password': passwordController.text,
            'dob': selectedDOB!.toIso8601String(),
            'designation': selectedDesignation,
            'shift': selectedShift,
            'addedBy': employeeId,
          }),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Employee added successfully!')),
          );
          _clearForm();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error: ${jsonDecode(response.body)['error']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Error: Employee ID not found in SharedPreferences')),
        );
      }
    }
  }

  void _clearForm() {
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
    _formKey.currentState
        ?.reset(); // Reset form state to clear validation errors
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
                    child: Form(
                      key: _formKey,
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
                                      firstNameController, "First Name",
                                      isAlphabetOnly: true),
                                  buildTextField(
                                      lastNameController, "Last Name",
                                      isAlphabetOnly: true),
                                  buildTextField(emailController, "Email",
                                      isEmail: true),
                                  buildTextField(cnicController, "CNIC",
                                      isNumeric: true),
                                  buildTextField(
                                      phoneController, "Phone Number",
                                      isNumeric: true),
                                  buildTextField(
                                    salaryController,
                                    "Salary",
                                  ),
                                  buildTextField(
                                      usernameController, "Username"),
                                  buildTextField(passwordController, "Password",
                                      obscureText: true),
                                  buildDateOfBirthField(context),
                                  buildDropdown(
                                      "Select Designation", designations,
                                      (value) {
                                    setState(() {
                                      selectedDesignation = value;
                                    });
                                  }, selectedDesignation),
                                  buildDropdown("Select Shift", shifts,
                                      (value) {
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
              ),
            )
          ],
        ),
      ),
    );
  }

// Build Text Field with Updated Validation
  Widget buildTextField(TextEditingController controller, String hintText,
      {bool obscureText = false,
      bool isEmail = false,
      bool isNumeric = false,
      bool isAlphabetOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        autovalidateMode:
            AutovalidateMode.onUserInteraction, // Enable real-time validation
        decoration: InputDecoration(
          labelText: hintText,
          labelStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.red, width: 2.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.red, width: 2.0),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty && hintText != "Last Name") {
            return 'Please enter $hintText';
          }
          if (isEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
            return 'Please enter a valid email address';
          }
          if (isNumeric) {
            if (hintText == "CNIC" &&
                (value.length != 13 || !RegExp(r'^[0-9]+$').hasMatch(value))) {
              return 'CNIC must be 13 digits';
            } else if (hintText == "Phone Number" &&
                (value.length != 11 || !RegExp(r'^[0-9]+$').hasMatch(value))) {
              return 'Phone Number must be 11 digits';
            }
          }
          if (isAlphabetOnly && !RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
            if (hintText == "Last Name" && value.isEmpty) {
              return null;
            }
            return 'Only alphabets are allowed';
          }
          if (hintText == "Salary") {
            double? salary = double.tryParse(value);
            if (salary == null || salary < 20000 || salary > 10000000) {
              return 'Salary must be between 20000 and 10000000';
            }
          }
          if (hintText == "Password") {
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
              return 'Password must contain at least one uppercase letter';
            }
            if (!RegExp(r'(?=.*[a-z])').hasMatch(value)) {
              return 'Password must contain at least one lowercase letter';
            }
            if (!RegExp(r'(?=.*[0-9])').hasMatch(value)) {
              return 'Password must contain at least one number';
            }
          }
          return null;
        },
      ),
    );
  }

  // Build Date of Birth Field with Validation
  DateTime currentDate = DateTime.now();

  Widget buildDateOfBirthField(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDOB ??
              (currentDate.isBefore(DateTime(2007))
                  ? currentDate
                  : DateTime(2007)), // Set dynamically to current date or 2006
          firstDate: DateTime(1900),
          lastDate: DateTime(2007),
        );

        if (picked != null && picked != selectedDOB) {
          setState(() {
            selectedDOB = picked;
          });
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
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
          validator: (value) {
            if (selectedDOB == null) {
              return 'Please select a Date of Birth';
            }
            return null;
          },
        ),
      ),
    );
  }

  // Build Dropdown Menu with Validation
  Widget buildDropdown(String hintText, List<String> items,
      Function(String?) onChanged, String? selectedValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
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
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a $hintText';
          }
          return null;
        },
      ),
    );
  }
}
