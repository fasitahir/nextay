import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String? apiUrl = dotenv.env['IP'];
final String? apiPort = dotenv.env['PORT'];

// Update phone pattern to require 11 digits starting with 0
final RegExp phonePattern = RegExp(r'^0\d{10}$');
final RegExp emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
final RegExp namePattern =
    RegExp(r"^[a-zA-Z]+(([',. -][a-zA-Z ])?[a-zA-Z]*)*$");

class CustomerData {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String address;
  final String dob;
  final String nationality;
  final int idType;
  final String? preferences;

  CustomerData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.dob,
    required this.nationality,
    required this.idType,
    this.preferences,
  });

  Map<String, dynamic> toJson() => {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone_number': phoneNumber,
        'address': address,
        'dob': dob,
        'nationality': nationality,
        'id_type': idType,
        'preferences': preferences,
      };
}

// Add ValidationState class to manage form validation
class ValidationState {
  String? firstNameError;
  String? lastNameError;
  String? emailError;
  String? phoneError;
  String? addressError;
  String? dobError;
  String? nationalityError;
  String? numberOfGuestsError;

  bool get isValid {
    return firstNameError == null &&
        lastNameError == null &&
        emailError == null &&
        phoneError == null &&
        addressError == null &&
        dobError == null &&
        nationalityError == null &&
        numberOfGuestsError == null;
  }
}

class StaffRoomsPage extends StatefulWidget {
  const StaffRoomsPage({super.key});

  @override
  _StaffRoomsPageState createState() => _StaffRoomsPageState();
}

class _StaffRoomsPageState extends State<StaffRoomsPage> {
  List<Map<String, dynamic>> rooms = [];
  bool _isLoading = true;

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
                    'check_in_time': room['check_in_time'],
                    'check_out_time': room['check_out_time'],
                    'amenities': List<String>.from(room['amenities'] ?? []),
                  })
              .toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load rooms');
      }
    } catch (e) {
      print('Error fetching rooms: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading rooms: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> checkInRoom(int index) async {
    final room = rooms[index];
    int numberOfGuests = 1;
    final validationState = ValidationState();

    CustomerData? customerData = await showDialog<CustomerData>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String firstName = '';
        String lastName = '';
        String email = '';
        String phoneNumber = '';
        String address = '';
        String dob = '';
        String nationality = '';
        int idType = 11;
        String preferences = '';

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            void validateFirstName(String value) {
              setState(() {
                if (value.isEmpty) {
                  validationState.firstNameError = 'First name is required';
                } else if (!namePattern.hasMatch(value)) {
                  validationState.firstNameError = 'Enter a valid first name';
                } else if (value.length < 2) {
                  validationState.firstNameError =
                      'Name must be at least 2 characters';
                } else {
                  validationState.firstNameError = null;
                }
              });
            }

            void validateLastName(String value) {
              setState(() {
                if (value.isEmpty) {
                  validationState.lastNameError = 'Last name is required';
                } else if (!namePattern.hasMatch(value)) {
                  validationState.lastNameError = 'Enter a valid last name';
                } else if (value.length < 2) {
                  validationState.lastNameError =
                      'Name must be at least 2 characters';
                } else {
                  validationState.lastNameError = null;
                }
              });
            }

            void validateEmail(String value) {
              setState(() {
                if (value.isEmpty) {
                  validationState.emailError = 'Email is required';
                } else if (!emailPattern.hasMatch(value)) {
                  validationState.emailError = 'Enter a valid email address';
                } else {
                  validationState.emailError = null;
                }
              });
            }

            void validatePhone(String value) {
              setState(() {
                if (value.isEmpty) {
                  validationState.phoneError = 'Phone number is required';
                } else if (!phonePattern.hasMatch(value)) {
                  validationState.phoneError =
                      'Phone number must start with 0 and be exactly 11 digits';
                } else {
                  validationState.phoneError = null;
                }
              });
            }

            void validateAddress(String value) {
              setState(() {
                if (value.isEmpty) {
                  validationState.addressError = 'Address is required';
                } else if (value.length < 5) {
                  validationState.addressError = 'Address is too short';
                } else {
                  validationState.addressError = null;
                }
              });
            }

            void validateNationality(String value) {
              setState(() {
                if (value.isEmpty) {
                  validationState.nationalityError = 'Nationality is required';
                } else if (!namePattern.hasMatch(value)) {
                  validationState.nationalityError =
                      'Enter a valid nationality';
                } else {
                  validationState.nationalityError = null;
                }
              });
            }

            void validateNumberOfGuests(String value) {
              setState(() {
                final number = int.tryParse(value);
                if (number == null || number < 1) {
                  validationState.numberOfGuestsError =
                      'Enter a valid number of guests';
                } else if (number > room['max_occupancy']) {
                  validationState.numberOfGuestsError =
                      'Cannot exceed maximum occupancy (${room['max_occupancy']})';
                } else {
                  validationState.numberOfGuestsError = null;
                }
              });
            }

            return AlertDialog(
              title: const Text('Customer Check-in'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'First Name*',
                        errorText: validationState.firstNameError,
                      ),
                      onChanged: (value) {
                        firstName = value;
                        validateFirstName(value);
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Last Name*',
                        errorText: validationState.lastNameError,
                      ),
                      onChanged: (value) {
                        lastName = value;
                        validateLastName(value);
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Email*',
                        errorText: validationState.emailError,
                      ),
                      onChanged: (value) {
                        email = value;
                        validateEmail(value);
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Phone Number*',
                        errorText: validationState.phoneError,
                        hintText: '0XXXXXXXXXX',
                      ),
                      keyboardType: TextInputType.phone,
                      maxLength: 11,
                      onChanged: (value) {
                        phoneNumber = value;
                        validatePhone(value);
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Address*',
                        errorText: validationState.addressError,
                      ),
                      onChanged: (value) {
                        address = value;
                        validateAddress(value);
                      },
                    ),
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().subtract(
                              const Duration(days: 6570)), // 18 years ago
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            dob = DateFormat('yyyy-MM-dd').format(picked);
                            // Validate age
                            final age =
                                DateTime.now().difference(picked).inDays ~/ 365;
                            if (age < 18) {
                              validationState.dobError =
                                  'Must be at least 18 years old';
                            } else {
                              validationState.dobError = null;
                            }
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Date of Birth*',
                          errorText: validationState.dobError,
                        ),
                        child: Text(
                          dob.isEmpty ? 'Select Date' : dob,
                        ),
                      ),
                    ),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Nationality*',
                        errorText: validationState.nationalityError,
                      ),
                      onChanged: (value) {
                        nationality = value;
                        validateNationality(value);
                      },
                    ),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: 'ID Type*'),
                      value: idType,
                      items: const [
                        DropdownMenuItem(value: 9, child: Text('Passport')),
                        DropdownMenuItem(
                            value: 10, child: Text('Driver License')),
                        DropdownMenuItem(
                            value: 11, child: Text('National ID Card')),
                      ],
                      onChanged: (value) => idType = value!,
                    ),
                    TextField(
                      decoration:
                          const InputDecoration(labelText: 'Preferences'),
                      onChanged: (value) => preferences = value,
                    ),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Number of Guests*',
                        errorText: validationState.numberOfGuestsError,
                        hintText: 'Maximum: ${room['max_occupancy']}',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        numberOfGuests = int.tryParse(value) ?? 1;
                        validateNumberOfGuests(value);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Check In'),
                  onPressed: () {
                    // Validate all fields one last time
                    validateFirstName(firstName);
                    validateLastName(lastName);
                    validateEmail(email);
                    validatePhone(phoneNumber);
                    validateAddress(address);
                    validateNationality(nationality);
                    validateNumberOfGuests(numberOfGuests.toString());

                    if (dob.isEmpty) {
                      setState(() {
                        validationState.dobError = 'Date of birth is required';
                      });
                      return;
                    }

                    if (!validationState.isValid) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Please correct the errors in the form'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    Navigator.of(context).pop(CustomerData(
                      firstName: firstName,
                      lastName: lastName,
                      email: email,
                      phoneNumber: phoneNumber,
                      address: address,
                      dob: dob,
                      nationality: nationality,
                      idType: idType,
                      preferences: preferences,
                    ));
                  },
                ),
              ],
            );
          },
        );
      },
    );

    if (customerData == null) return;

    try {
      final roomId = rooms[index]['id'];
      final totalAmount = room['price_per_day'];

      // First save customer data
      final customerResponse = await http.post(
        Uri.parse('http://$apiUrl:$apiPort/customer'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
        body: json.encode({
          'first_name': customerData.firstName,
          'last_name': customerData.lastName,
          'email': customerData.email,
          'phone_number': customerData.phoneNumber,
          'address': customerData.address,
          'dob': customerData.dob,
          'nationality': customerData.nationality,
          'id_type': customerData.idType,
          'preferences': customerData.preferences,
        }),
      );

      if (customerResponse.statusCode != 201) {
        final errorData = json.decode(customerResponse.body);
        throw Exception(errorData['error'] ?? 'Failed to save customer data');
      }

      final responseData = json.decode(customerResponse.body);
      final customerId = responseData['customer_id'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? employeeId = prefs.getInt('employeeId');

      // Create booking
      final bookingResponse = await http.post(
        Uri.parse('http://$apiUrl:$apiPort/booking'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
        body: json.encode({
          'customer_id': customerId,
          'room_id': roomId,
          'check_in_date': DateTime.now().toIso8601String(),
          'number_of_guests': numberOfGuests,
          'special_request': customerData.preferences,
          'total_amount': totalAmount,
          'booked_by': employeeId
        }),
      );

      if (bookingResponse.statusCode != 201) {
        final errorData = json.decode(bookingResponse.body);
        throw Exception(errorData['error'] ?? 'Failed to create booking');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Room checked in successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Check in the room
      final checkInResponse = await http.put(
        Uri.parse('http://$apiUrl:$apiPort/rooms/$roomId/checkin'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
        body: json.encode({
          'customer_id': customerId,
          'check_in_date': DateTime.now().toIso8601String(),
          'number_of_guests': numberOfGuests,
          'total_amount': totalAmount,
          'special_request': customerData.preferences,
          'booked_by': employeeId
        }),
      );

      if (checkInResponse.statusCode == 200) {
        setState(() {
          rooms[index]['room_status'] = 'Occupied';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Room checked in successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errorData = json.decode(checkInResponse.body);
        throw Exception(errorData['error'] ?? 'Failed to check-in room');
      }
    } catch (e) {
      print('Error checking in room: $e');
      print('Stack Trace: ${StackTrace.current}');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Error checking in room: $e'),
      //     backgroundColor: Colors.red,
      //   ),
      // );
    }
  }

  Future<void> checkOutRoom(int index) async {
    try {
      final room = rooms[index];
      final roomId = room['id'];

      // Calculate total bill
      double totalBill = room['price_per_day'];
      if (room['check_in_time'] != null && room['check_out_time'] != null) {
        final checkIn = DateTime.parse(room['check_in_time']);
        final checkOut = DateTime.parse(room['check_out_time']);
        final duration = checkOut.difference(checkIn).inDays;
        totalBill = room['price_per_day'] * duration;
      }

      final response = await http.put(
        Uri.parse('http://$apiUrl:$apiPort/rooms/$roomId/checkout'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        setState(() {
          rooms[index]['room_status'] = 'Dirty';
        });

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Checkout Bill'),
            content: Text(
                'Total Bill for Room ${room['id']}: \$${totalBill.toStringAsFixed(2)}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        throw Exception('Failed to checkout room');
      }
    } catch (e) {
      print('Error checking out room: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking out room: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> cleanRoom(int index) async {
    try {
      final roomId = rooms[index]['id'];
      final response = await http.put(
        Uri.parse('http://$apiUrl:$apiPort/rooms/$roomId/clean'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        setState(() {
          rooms[index]['room_status'] = 'Available';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Room marked as clean!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to clean room');
      }
    } catch (e) {
      print('Error cleaning room: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error cleaning room: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildSummarySection(
      double screenHeight, double screenWidth, bool isWeb) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: screenHeight * 0.01,
        horizontal: screenWidth * 0.03,
      ),
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
        child: isWeb
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: _buildSummaryCards(),
                ),
              )
            : Column(
                children: _buildSummaryCards(),
              ),
      ),
    );
  }

  List<Widget> _buildSummaryCards() {
    return [
      _buildSummaryCard("Total Rooms", "${rooms.length}"),
      _buildSummaryCard("Occupied",
          "${rooms.where((r) => r['room_status'] == 'Occupied').length}"),
      _buildSummaryCard("Available",
          "${rooms.where((r) => r['room_status'] == 'Available').length}"),
      _buildSummaryCard("Cleaning",
          "${rooms.where((r) => r['room_status'] == 'Dirty').length}"),
    ];
  }

  Widget _buildSummaryCard(String title, String count) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Material(
        elevation: 10,
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[100],
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
          width: 200,
          height: 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                count,
                style: TextStyle(
                  color: Colors.blueGrey[900],
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  color: Colors.blueGrey[700],
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCardColor(String status) {
    switch (status) {
      case 'Occupied':
        return Colors.red[100] ?? Colors.red;
      case 'Dirty':
        return Colors.yellow[100] ?? Colors.yellow;
      case 'Available':
        return Colors.green[100] ?? Colors.green;
      default:
        return Colors.white;
    }
  }

  Widget _buildTrailingButtons(int index) {
    final status = rooms[index]['room_status'];
    final isAvailable = status == 'Available';
    final isDirty = status == 'Dirty';
    final isOccupied = status == 'Occupied';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isAvailable)
          IconButton(
            icon: const Icon(Icons.check_box),
            onPressed: () => checkInRoom(index),
          ),
        if (isDirty)
          IconButton(
            icon: const Icon(Icons.cleaning_services),
            onPressed: () => cleanRoom(index),
          ),
        if (isOccupied)
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => checkOutRoom(index),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWeb = screenWidth > 800;

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
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
                          "Room Management",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  _buildSummarySection(screenHeight, screenWidth, isWeb),
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
                            color: _getCardColor(room['room_status']),
                            elevation: 4,
                            child: ListTile(
                              title: Text(
                                'Room ${room['id']} - ${room['room_type']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Price: \$${room['price_per_day']}'),
                                  Text(
                                      'Max Occupancy: ${room['max_occupancy']}'),
                                  Text('Status: ${room['room_status']}'),
                                  Text('Bed Type: ${room['bed_type']}'),
                                  Text(
                                      'Amenities: ${(room['amenities'] as List).join(', ')}'),
                                ],
                              ),
                              trailing: _buildTrailingButtons(index),
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
