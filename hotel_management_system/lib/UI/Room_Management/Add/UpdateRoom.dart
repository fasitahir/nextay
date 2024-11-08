import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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

  @override
  void initState() {
    super.initState();
    fetchRooms(); // Fetch room data when the widget is initialized
  }

  // Fetch room data from the API
  Future<void> fetchRooms() async {
    try {
      final response = await http.get(Uri.parse(
          'http://$apiUrl:$apiPort/rooms')); // Update with your API URL

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
                    'last_cleaned': room['last_cleaned'],
                    'last_maintenance_date': room['last_maintenance_date'],
                    'image_id': room['image_id'],
                  })
              .toList();
        });
      } else {
        throw Exception('Failed to load rooms');
      }
    } catch (e) {
      // Handle the error
      print('Error fetching rooms: $e');
    }
  }

  // Function to delete room
  Future<void> deleteRoom(int index) async {
    try {
      final roomId = rooms[index]['id'];
      final response = await http.delete(
        Uri.parse('http://$apiUrl:$apiPort/room/$roomId'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        setState(() {
          rooms.removeAt(index); // Remove room from the UI
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Room deleted successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete room: ${response.body}')),
        );
      }
    } catch (e) {
      print('Error deleting room: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting room: $e')),
      );
    }
  }

  // Function to update room
  Future<void> updateRoom(int index) async {
    TextEditingController roomTypeController =
        TextEditingController(text: rooms[index]['room_type']);
    TextEditingController priceController =
        TextEditingController(text: rooms[index]['price_per_day'].toString());
    TextEditingController roomAreaController =
        TextEditingController(text: rooms[index]['room_area'].toString());
    TextEditingController floorNumberController =
        TextEditingController(text: rooms[index]['floor_number'].toString());
    TextEditingController maxOccupancyController =
        TextEditingController(text: rooms[index]['max_occupancy'].toString());
    TextEditingController bedTypeController =
        TextEditingController(text: rooms[index]['bed_type']);
    TextEditingController roomStatusController =
        TextEditingController(text: rooms[index]['room_status']);
    TextEditingController lastCleanedController =
        TextEditingController(text: rooms[index]['last_cleaned']);
    TextEditingController lastMaintenanceController =
        TextEditingController(text: rooms[index]['last_maintenance_date']);
    TextEditingController imageIdController =
        TextEditingController(text: rooms[index]['image_id'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update Room"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: roomTypeController,
                  decoration: const InputDecoration(labelText: "Room Type"),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: "Price Per Day"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: roomAreaController,
                  decoration: const InputDecoration(labelText: "Room Area"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: floorNumberController,
                  decoration: const InputDecoration(labelText: "Floor Number"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: maxOccupancyController,
                  decoration: const InputDecoration(labelText: "Max Occupancy"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: bedTypeController,
                  decoration: const InputDecoration(labelText: "Bed Type"),
                ),
                TextField(
                  controller: roomStatusController,
                  decoration: const InputDecoration(labelText: "Room Status"),
                ),
                TextField(
                  controller: lastCleanedController,
                  decoration: const InputDecoration(labelText: "Last Cleaned"),
                ),
                TextField(
                  controller: lastMaintenanceController,
                  decoration:
                      const InputDecoration(labelText: "Last Maintenance Date"),
                ),
                TextField(
                  controller: imageIdController,
                  decoration: const InputDecoration(labelText: "Image ID"),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Call the API to update the room
                final response = await http.put(
                  Uri.parse(
                      'http://$apiUrl:$apiPort/room/${rooms[index]['id']}'), // Use your API URL
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode({
                    'room_type': roomTypeController.text,
                    'price_per_day': double.parse(priceController.text),
                    'room_area': double.parse(roomAreaController.text),
                    'floor_number': int.parse(floorNumberController.text),
                    'max_occupancy': int.parse(maxOccupancyController.text),
                    'bed_type': bedTypeController.text,
                    'room_status': roomStatusController.text,
                    'last_cleaned': lastCleanedController.text,
                    'last_maintenance_date': lastMaintenanceController.text,
                    'image_id': int.parse(imageIdController.text),
                  }),
                );

                if (response.statusCode == 200) {
                  setState(() {
                    rooms[index] = {
                      'id': rooms[index]['id'], // Preserve the ID
                      'room_type': roomTypeController.text,
                      'price_per_day': double.parse(priceController.text),
                      'room_area': double.parse(roomAreaController.text),
                      'floor_number': int.parse(floorNumberController.text),
                      'max_occupancy': int.parse(maxOccupancyController.text),
                      'bed_type': bedTypeController.text,
                      'room_status': roomStatusController.text,
                      'last_cleaned': lastCleanedController.text,
                      'last_maintenance_date': lastMaintenanceController.text,
                      'image_id': int.parse(imageIdController.text),
                    };
                  });
                  Navigator.of(context).pop();
                } else {
                  // Handle the error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Failed to update room: ${response.body}')),
                  );
                }
              },
              child: const Text("Update"),
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
            Center(
              child: Container(
                width: screenWidth * 0.9,
                height: screenHeight * 0.75,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(40)),
                ),
                child: ListView.builder(
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.all(10),
                      elevation: 4,
                      child: ListTile(
                        title: Text(
                          'Room Type: ${rooms[index]['room_type']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Price: \$${rooms[index]['price_per_day']}'),
                            Text(
                                'Max Occupancy: ${rooms[index]['max_occupancy']}'),
                            Text('Status: ${rooms[index]['room_status']}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () =>
                                  updateRoom(index), // Call the update function
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  deleteRoom(index), // Call the delete function
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
