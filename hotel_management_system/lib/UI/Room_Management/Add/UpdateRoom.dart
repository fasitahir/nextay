import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String? apiUrl = dotenv.env['IP'];
final String? apiPort = dotenv.env['PORT'];

class RoomUpdate extends StatefulWidget {
  const RoomUpdate({super.key});

  @override
  RoomUpdateState createState() => RoomUpdateState();
}

class RoomUpdateState extends State<RoomUpdate> {
  List<Map<String, dynamic>> rooms = [];
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

  @override
  void initState() {
    super.initState();
    fetchRooms();
  }

  Future<void> fetchRooms() async {
    try {
      final response =
          await http.get(Uri.parse('http://$apiUrl:$apiPort/rooms'));

      if (response.statusCode == 200) {
        final List<dynamic> roomData = json.decode(response.body);
        setState(() {
          rooms = roomData
              .map((room) => {
                    'id': room['id'],
                    'room_type': room['room_type'],
                    'price_per_day': room['price_per_day'],
                    'room_area': room['room_area'],
                    'floor_number': room['floor_number'],
                    'max_occupancy': room['max_occupancy'],
                    'bed_type': room['bed_type'],
                    'room_status': room['room_status'],
                    'last_maintenance_date': room['last_maintenance_date'],
                    'amenities': List<String>.from(room['amenities'] ?? []),
                  })
              .toList();
        });
      } else {
        throw Exception('Failed to load rooms');
      }
    } catch (e) {
      print('Error fetching rooms: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading rooms: $e')),
      );
    }
  }

  Future<void> deleteRoom(int index) async {
    try {
      // Get employee ID from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? employeeId = prefs.getInt('employeeId');

      if (employeeId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Employee ID not found'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final roomId = rooms[index]['id'];
      final response = await http.delete(
        Uri.parse(
            'http://$apiUrl:$apiPort/room/$roomId?updated_by=$employeeId'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        setState(() {
          rooms.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Room deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errorResponse = json.decode(response.body);
        throw Exception(errorResponse['error'] ?? 'Failed to delete room');
      }
    } catch (e) {
      print('Error deleting room: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting room: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> updateRoom(int index) async {
    final room = rooms[index];
    final _formKey = GlobalKey<FormState>();

    TextEditingController priceController =
        TextEditingController(text: room['price_per_day'].toString());
    TextEditingController roomAreaController =
        TextEditingController(text: room['room_area'].toString());
    TextEditingController floorNumberController =
        TextEditingController(text: room['floor_number'].toString());
    TextEditingController maxOccupancyController =
        TextEditingController(text: room['max_occupancy'].toString());
    TextEditingController bedTypeController =
        TextEditingController(text: room['bed_type']);
    String selectedRoomType = room['room_type'];
    String selectedRoomStatus = room['room_status'];
    List<String> selectedAmenities = List<String>.from(room['amenities']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update Room"),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildDropdown(
                    "Room Type",
                    roomTypes,
                    (value) {
                      setState(() {
                        selectedRoomType = value!;
                      });
                    },
                    selectedRoomType,
                  ),
                  buildTextField(
                    priceController,
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
                        selectedRoomStatus = value!;
                      });
                    },
                    selectedRoomStatus,
                  ),
                  buildAmenitiesSelection(selectedAmenities),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  try {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    int? employeeId = prefs.getInt('employeeId');

                    if (employeeId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Error: Employee ID not found'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final response = await http.put(
                      Uri.parse('http://$apiUrl:$apiPort/room/${room['id']}'),
                      headers: {"Content-Type": "application/json"},
                      body: jsonEncode({
                        'room_type': selectedRoomType,
                        'price_per_day': double.parse(priceController.text),
                        'room_area': double.parse(roomAreaController.text),
                        'floor_number': int.parse(floorNumberController.text),
                        'max_occupancy': int.parse(maxOccupancyController.text),
                        'bed_type': bedTypeController.text,
                        'room_status': selectedRoomStatus,
                        'amenities': selectedAmenities,
                        'updated_by': employeeId,
                      }),
                    );

                    if (response.statusCode == 200) {
                      Navigator.of(context).pop();
                      fetchRooms();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Room updated successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      throw Exception(
                          'Failed to update room: ${response.body}');
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error updating room: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text("Update"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
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
    String selectedItem,
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

  Widget buildAmenitiesSelection(List<String> selectedAmenities) {
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
                    "Manage Room Data",
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
                width: screenWidth * 0.9,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(40)),
                ),
                child: ListView.builder(
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      elevation: 4,
                      child: ListTile(
                        title: Text(
                          'Room Type: ${room['room_type']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Price: \$${room['price_per_day']}'),
                            Text('Max Occupancy: ${room['max_occupancy']}'),
                            Text('Status: ${room['room_status']}'),
                            Text(
                                'Amenities: ${(room['amenities'] as List).join(', ')}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => updateRoom(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Room'),
                                  content: const Text(
                                      'Are you sure you want to delete this room?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        deleteRoom(index);
                                      },
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
