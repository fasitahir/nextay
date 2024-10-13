import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class AddEmployee extends StatefulWidget {
  const AddEmployee({super.key});

  @override
  AddEmployeeState createState() => AddEmployeeState();
}

class AddEmployeeState extends State<AddEmployee> {
  // Controllers
  final TextEditingController eFirstName = TextEditingController();
  final TextEditingController eLastName = TextEditingController();
  final TextEditingController eEmail = TextEditingController();
  final TextEditingController ePhoneNumber = TextEditingController();
  final TextEditingController eAddress = TextEditingController();

  // Date of Birth and Shift
  String? selectedShift;
  DateTime? selectedDOB;

  @override
  Widget build(BuildContext context) {
    double screenheight = MediaQuery.of(context).size.height;
    double screenwidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          
          gradient: LinearGradient(begin: Alignment.topCenter, colors: [
            Colors.blueGrey[900] ?? Colors.blueGrey,
            Colors.blueGrey[700] ?? Colors.blueGrey,
            Colors.blueGrey[400] ?? Colors.blueGrey,
          ]),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: screenheight * 0.07),
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: screenheight * 0.01,
                  horizontal: screenwidth * 0.03),
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
                  SizedBox(height: screenheight * 0.01),
                ],
              ),
            ),
            SizedBox(height: screenheight * 0.001),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(
                    horizontal: screenwidth * 0.03,
                    vertical: screenheight * 0.02),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: screenheight * 0.01,
                      horizontal: screenwidth * 0.03),
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: screenheight * 0.08),
                        FadeInUp(
                          duration: const Duration(milliseconds: 1400),
                          child: Container(
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
                                // First Name
                                buildTextField(eFirstName, "First Name"),
                                // Last Name
                                buildTextField(eLastName, "Last Name"),
                                // Email
                                buildTextField(eEmail, "Email"),
                                // Date of Birth (Date Picker)
                                buildDateSelector(context),
                                // Shift (Dropdown)
                                buildShiftDropdown(),
                                // Phone Number
                                buildTextField(ePhoneNumber, "Phone Number"),
                                // Address
                                buildTextField(eAddress, "Address"),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: screenheight * 0.03),
                        SizedBox(height: screenheight * 0.09),
                        FadeInUp(
                          duration: const Duration(milliseconds: 1600),
                          child: MaterialButton(
                            onPressed: () {
                              // Implement submission logic
                            },
                            height: 50,
                            color: Colors.blueGrey[600] ?? Colors.blueGrey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Center(
                              child: Text(
                                "Submit",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
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
  Widget buildTextField(TextEditingController controller, String hintText) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // Build Date Selector Widget (Date of Birth)
  Widget buildDateSelector(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() {
            selectedDOB = picked;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedDOB == null
                    ? "Select Date of Birth"
                    : "${selectedDOB!.day}-${selectedDOB!.month}-${selectedDOB!.year}",
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            const Icon(Icons.calendar_today, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // Build Shift Dropdown Widget
  Widget buildShiftDropdown() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
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
            selectedShift = newValue;
          });
        },
      ),
    );
  }
}
