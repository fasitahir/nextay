import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String? apiUrl = dotenv.env['IP'];
final String? apiPort = dotenv.env['PORT'];

class AddRoomScreen extends StatefulWidget {
  const AddRoomScreen({super.key});

  @override
  _AddRoomScreenState createState() => _AddRoomScreenState();
}

class _AddRoomScreenState extends State<AddRoomScreen> {
  final TextEditingController roomTypeController = TextEditingController();
  final TextEditingController pricePerDayController = TextEditingController();
  final TextEditingController roomAreaController = TextEditingController();
  final TextEditingController floorNumberController = TextEditingController();
  final TextEditingController maxOccupancyController = TextEditingController();
  final TextEditingController bedTypeController = TextEditingController();

  DateTime? selectedLastCleaned;
  DateTime? selectedLastMaintenanceDate;
  String? selectedRoomStatus;
  String? selectedImageId;

  final List<String> roomStatuses = [
    'Available',
    'Occupied',
    'Under Maintenance',
    'Reserved'
  ];
  final List<String> images = [
    '1', // Assuming these are Image IDs
    '2',
    '3',
    '4'
  ];

  void _submitRoom() async {
    final String roomType = roomTypeController.text;
    final String pricePerDay = pricePerDayController.text;
    final String roomArea = roomAreaController.text;
    final String floorNumber = floorNumberController.text;
    final String maxOccupancy = maxOccupancyController.text;
    final String bedType = bedTypeController.text;

    if (roomType.isNotEmpty &&
        pricePerDay.isNotEmpty &&
        roomArea.isNotEmpty &&
        floorNumber.isNotEmpty &&
        maxOccupancy.isNotEmpty &&
        bedType.isNotEmpty &&
        selectedRoomStatus != null &&
        selectedImageId != null &&
        selectedLastCleaned != null &&
        selectedLastMaintenanceDate != null) {
      final response = await http.post(
        Uri.parse('http://$apiUrl:$apiPort/room'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'room_type': roomType,
          'price_per_day': double.parse(pricePerDay),
          'room_area': double.parse(roomArea),
          'floor_number': int.parse(floorNumber),
          'max_occupancy': int.parse(maxOccupancy),
          'bed_type': bedType,
          'room_status': selectedRoomStatus,
          'image_id': int.parse(selectedImageId!),
          'last_cleaned': selectedLastCleaned!.toIso8601String(),
          'last_maintenance_date':
              selectedLastMaintenanceDate!.toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Room added successfully!')),
        );
        // Clear the form
        roomTypeController.clear();
        pricePerDayController.clear();
        roomAreaController.clear();
        floorNumberController.clear();
        maxOccupancyController.clear();
        bedTypeController.clear();
        setState(() {
          selectedRoomStatus = null;
          selectedImageId = null;
          selectedLastCleaned = null;
          selectedLastMaintenanceDate = null;
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
                      "Add Room Information",
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
                                buildTextField(roomTypeController, "Room Type"),
                                buildTextField(
                                    pricePerDayController, "Price Per Day"),
                                buildTextField(roomAreaController, "Room Area"),
                                buildTextField(
                                    floorNumberController, "Floor Number"),
                                buildTextField(
                                    maxOccupancyController, "Max Occupancy"),
                                buildTextField(bedTypeController, "Bed Type"),
                                buildDropdown(
                                    "Select Room Status", roomStatuses,
                                    (value) {
                                  setState(() {
                                    selectedRoomStatus = value;
                                  });
                                }, selectedRoomStatus),
                                buildDropdown("Select Image ID", images,
                                    (value) {
                                  setState(() {
                                    selectedImageId = value;
                                  });
                                }, selectedImageId),
                                buildDateOfBirthField(context, "Last Cleaned"),
                                buildDateOfBirthField(
                                    context, "Last Maintenance Date"),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.05),
                        FadeInUp(
                          duration: const Duration(milliseconds: 1600),
                          child: MaterialButton(
                            onPressed: _submitRoom,
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
        keyboardType: hintText.contains('Price') || hintText.contains('Number')
            ? TextInputType.number
            : TextInputType.text,
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

  // Build Date Field Widget
  Widget buildDateOfBirthField(BuildContext context, String label) {
    DateTime? selectedDate = label == "Last Cleaned"
        ? selectedLastCleaned
        : selectedLastMaintenanceDate;

    return GestureDetector(
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(1900), // Set a realistic starting point
          lastDate: DateTime.now(),
        );

        if (picked != selectedDate) {
          setState(() {
            if (label == "Last Cleaned") {
              selectedLastCleaned = picked;
            } else {
              selectedLastMaintenanceDate = picked;
            }
          });
        }
      },
      child: AbsorbPointer(
        child: TextField(
          controller: TextEditingController(
            text: selectedDate != null
                ? "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"
                : "",
          ),
          decoration: InputDecoration(
            labelText: label,
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
