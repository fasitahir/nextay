import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String? apiUrl = dotenv.env['IP'];
final String? apiPort = dotenv.env['PORT'];

class CustomerData {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String address;
  final String dob; // Change to String
  final String nationality;
  final int idType;
  final String? preferences;

  CustomerData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.dob, // Keep as String
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
        'dob': dob, // Store as String
        'nationality': nationality,
        'id_type': idType,
        'preferences': preferences,
      };
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
    CustomerData? customerData = await showDialog<CustomerData>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String firstName = '';
        String lastName = '';
        String email = '';
        String phoneNumber = '';
        String address = '';
        String dob = ''; // Change to String
        String nationality = '';
        int idType = 11; // Default to national id card
        String preferences = '';

        return AlertDialog(
          title: const Text('Customer Check-in'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'First Name*'),
                  onChanged: (value) => firstName = value,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Last Name*'),
                  onChanged: (value) => lastName = value,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Email*'),
                  onChanged: (value) => email = value,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Phone Number*'),
                  onChanged: (value) => phoneNumber = value,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Address*'),
                  onChanged: (value) => address = value,
                ),
                InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        dob = DateFormat('yyyy-MM-dd')
                            .format(picked); // Store as String
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration:
                        const InputDecoration(labelText: 'Date of Birth*'),
                    child: Text(
                      dob.isEmpty ? 'Select Date' : dob,
                    ),
                  ),
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Nationality*'),
                  onChanged: (value) => nationality = value,
                ),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'ID Type*'),
                  value: idType,
                  items: const [
                    DropdownMenuItem(value: 9, child: Text('Passport')),
                    DropdownMenuItem(value: 10, child: Text('Driver License')),
                    DropdownMenuItem(
                        value: 11, child: Text('National ID Card')),
                  ],
                  onChanged: (value) => idType = value!,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Preferences'),
                  onChanged: (value) => preferences = value,
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
                if (firstName.isEmpty ||
                    lastName.isEmpty ||
                    email.isEmpty ||
                    phoneNumber.isEmpty ||
                    address.isEmpty ||
                    dob.isEmpty ||
                    nationality.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please fill all required fields')),
                  );
                  return;
                }

                // Age validation
                final DateTime dobDate = DateTime.parse(dob);
                final int age = DateTime.now().year - dobDate.year;
                if (age < 18) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('You must be at least 18 years old')),
                  );
                  return;
                }

                Navigator.of(context).pop(CustomerData(
                  firstName: firstName,
                  lastName: lastName,
                  email: email,
                  phoneNumber: phoneNumber,
                  address: address,
                  dob: dob, // Store as String
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
    if (customerData == null) return;

    try {
      final roomId = rooms[index]['id'];

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
          'dob': customerData.dob, // Store as String
          'nationality': customerData.nationality,
          'id_type': customerData.idType,
          'preferences': customerData.preferences
        }),
      );
      print('Customer response status: ${customerResponse.statusCode}');
      print('Customer response body: ${customerResponse.body}');
      if (customerResponse.statusCode != 201) {
        final errorData = json.decode(customerResponse.body);
        throw Exception(errorData['error'] ?? 'Failed to save customer data');
      }

      final responseData = json.decode(customerResponse.body);
      final customerId = responseData['customer_id'];

      // Then check in the room
      final response = await http.put(
        Uri.parse('http://$apiUrl:$apiPort/rooms/$roomId/checkin'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
        body: json.encode({
          'customer_id': customerId,
          'check_in_date': DateTime.now().toString()
        }),
      );

      if (response.statusCode == 200) {
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
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to check-in room');
      }
    } catch (e) {
      print('Error checking in room: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking in room: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
