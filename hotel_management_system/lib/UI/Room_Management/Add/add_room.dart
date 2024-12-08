import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

final String? apiUrl = dotenv.env['IP'];
final String? apiPort = dotenv.env['PORT'];

class AddRoomScreen extends StatefulWidget {
  const AddRoomScreen({Key? key}) : super(key: key);

  @override
  _AddRoomScreenState createState() => _AddRoomScreenState();
}

class _AddRoomScreenState extends State<AddRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController pricePerDayController = TextEditingController();
  final TextEditingController roomAreaController = TextEditingController();
  final TextEditingController floorNumberController = TextEditingController();
  final TextEditingController maxOccupancyController = TextEditingController();
  final TextEditingController bedTypeController = TextEditingController();
  String? selectedRoomType;
  String? selectedRoomStatus;
  List<String> selectedAmenities = [];

  final List<String> roomTypes = [
    'Deluxe',
    'Standard',
    'Suite',
    'Economy',
    'Family'
  ];
  final List<String> roomStatuses = [
    'Available',
    'Occupied',
    'Under Maintenance',
    'Reserved'
  ];
  final List<String> availableAmenities = [
    'WiFi',
    'TV',
    'Air Conditioning',
    'Mini Bar',
    'Balcony',
    'Sea View',
    'Kitchenette',
    'Room Service'
  ];

  void _submitRoom() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Get employee ID from SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        int? employeeId = prefs.getInt('employeeId');

        if (employeeId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Error: Employee ID not found. Please login again.'),
            ),
          );
          return;
        }

        final response = await http.post(
          Uri.parse('http://$apiUrl:$apiPort/room'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            'room_type': selectedRoomType,
            'price_per_day': double.parse(pricePerDayController.text),
            'room_area': double.parse(roomAreaController.text),
            'floor_number': int.parse(floorNumberController.text),
            'max_occupancy': int.parse(maxOccupancyController.text),
            'bed_type': bedTypeController.text,
            'room_status': selectedRoomStatus,
            'amenities': selectedAmenities,
            'added_by':
                employeeId, // Using the employee ID from SharedPreferences
          }),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Room added successfully!')),
          );
          _clearForm();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${jsonDecode(response.body)['error']}'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // Rest of the code remains the same...
  void _clearForm() {
    pricePerDayController.clear();
    roomAreaController.clear();
    floorNumberController.clear();
    maxOccupancyController.clear();
    bedTypeController.clear();
    setState(() {
      selectedRoomType = null;
      selectedRoomStatus = null;
      selectedAmenities.clear();
    });
    _formKey.currentState?.reset();
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
                                  buildDropdown(
                                    "Room Type",
                                    roomTypes,
                                    (value) {
                                      setState(() {
                                        selectedRoomType = value;
                                      });
                                    },
                                    selectedRoomType,
                                  ),
                                  buildTextField(
                                    pricePerDayController,
                                    "Price Per Day",
                                    isNumeric: true,
                                    isPriceField: true,
                                  ),
                                  buildTextField(
                                    roomAreaController,
                                    "Room Area",
                                    isNumeric: true,
                                    isAreaField: true,
                                  ),
                                  buildTextField(
                                    floorNumberController,
                                    "Floor Number",
                                    isNumeric: true,
                                    isFloorField: true,
                                  ),
                                  buildTextField(
                                    maxOccupancyController,
                                    "Max Occupancy",
                                    isNumeric: true,
                                    isOccupancyField: true,
                                  ),
                                  buildTextField(
                                    bedTypeController,
                                    "Bed Type",
                                    isAlphabetOnly: true,
                                  ),
                                  buildDropdown(
                                    "Room Status",
                                    roomStatuses,
                                    (value) {
                                      setState(() {
                                        selectedRoomStatus = value;
                                      });
                                    },
                                    selectedRoomStatus,
                                  ),
                                  buildAmenitiesSelection(),
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
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildTextField(
    TextEditingController controller,
    String hintText, {
    bool isNumeric = false,
    bool isAlphabetOnly = false,
    bool isPriceField = false,
    bool isAreaField = false,
    bool isFloorField = false,
    bool isOccupancyField = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        autovalidateMode: AutovalidateMode.onUserInteraction,
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
            borderSide: const BorderSide(color: Colors.red, width: 2.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: const BorderSide(color: Colors.red, width: 2.0),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $hintText';
          }

          if (isNumeric) {
            if (!RegExp(r'^\d*\.?\d+$').hasMatch(value)) {
              return 'Please enter a valid number';
            }

            if (isPriceField) {
              double price = double.parse(value);
              if (price < 1000 || price > 1000000) {
                return 'Price must be between 1,000 and 1,000,000';
              }
            }

            if (isAreaField) {
              double area = double.parse(value);
              if (area < 100 || area > 10000) {
                return 'Area must be between 100 and 10,000 square feet';
              }
            }

            if (isFloorField) {
              int floor = int.parse(value);
              if (floor < -5 || floor > 100) {
                return 'Floor must be between -5 and 100';
              }
            }

            if (isOccupancyField) {
              int occupancy = int.parse(value);
              if (occupancy < 1 || occupancy > 10) {
                return 'Occupancy must be between 1 and 10';
              }
            }
          }

          if (isAlphabetOnly && !RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
            return 'Only alphabets and spaces are allowed';
          }

          return null;
        },
      ),
    );
  }

  Widget buildDropdown(
    String hint,
    List<String> items,
    ValueChanged<String?> onChanged,
    String? selectedItem,
  ) {
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
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a $hint';
          }
          return null;
        },
      ),
    );
  }

  Widget buildAmenitiesSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: FormField<List<String>>(
        initialValue: selectedAmenities,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select at least one amenity';
          }
          return null;
        },
        builder: (FormFieldState<List<String>> state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select Amenities",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 8.0),
              Wrap(
                spacing: 10.0,
                children: availableAmenities.map((amenity) {
                  return FilterChip(
                    label: Text(amenity),
                    selected: selectedAmenities.contains(amenity),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          selectedAmenities.add(amenity);
                        } else {
                          selectedAmenities.remove(amenity);
                        }
                        state.didChange(selectedAmenities);
                      });
                    },
                  );
                }).toList(),
              ),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    state.errorText!,
                    style: TextStyle(color: Colors.red[700], fontSize: 12),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
