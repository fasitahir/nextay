import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/scheduler.dart';

// Room class definition
class Room {
  final String id;
  final String type;
  final String status;
  final String lastCleaned;
  final String needsCleaning;
  final String pricePerDay;
  final String? roomArea;
  final String floorNumber;
  final String maxOccupancy;
  final String bedType;
  final String lastMaintenanceDate;

  Room({
    required this.id,
    required this.type,
    required this.status,
    required this.lastCleaned,
    required this.needsCleaning,
    required this.pricePerDay,
    this.roomArea,
    required this.floorNumber,
    required this.maxOccupancy,
    required this.bedType,
    required this.lastMaintenanceDate,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      type: json['type'],
      status: json['status'],
      lastCleaned: json['last_cleaned'],
      needsCleaning: json['status'],
      pricePerDay: json['price_per_day'],
      roomArea: json['room_area'],
      floorNumber: json['floor_number'],
      maxOccupancy: json['max_occupancy'],
      bedType: json['bed_type'],
      lastMaintenanceDate: json['last_maintenance_date'],
    );
  }
}

// StaffRoomsPage
class StaffRoomsPage extends StatefulWidget {
  @override
  _StaffRoomsPageState createState() => _StaffRoomsPageState();
}

class _StaffRoomsPageState extends State<StaffRoomsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Room> _rooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    fetchRooms();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  Future<void> fetchRooms() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:5000/rooms'));

      if (response.statusCode == 200) {
        List<dynamic> roomData = json.decode(response.body);
        setState(() {
          _rooms = roomData.map((roomJson) => Room.fromJson(roomJson)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load rooms');
      }
    } catch (error) {
      print('Error fetching rooms: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkInRoom(int index) {
    setState(() {
      // Implement your logic here
    });
  }

  void _cleanRoom(int index) {
    setState(() {
      // Implement your logic here
    });
  }

  void _checkOutRoom(int index) {
    String totalBill = _rooms[index].pricePerDay; // Example: One day stay
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Checkout Bill'),
          content: Text(
              'Total Bill for Room ${_rooms[index].id}: \$${totalBill[2]}'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  // Implement your logic here
                });
                Navigator.of(context).pop();
              },
              child: Text('Pay & Checkout'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
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
    bool isWeb = screenWidth > 800;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Staff Room Management Page",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildRoomManagementUI(screenHeight, screenWidth, isWeb),
    );
  }

  Widget _buildRoomManagementUI(
      double screenHeight, double screenWidth, bool isWeb) {
    return Container(
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
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.04),
            _buildSummarySection(screenHeight, screenWidth, isWeb),
            SizedBox(height: screenHeight * 0.02),
            _buildRoomList(screenHeight),
          ],
        ),
      ),
    );
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
        child: Column(
          children: [
            FadeTransition(
              opacity: _controller,
              child: isWeb
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _buildSummaryCard("Total Rooms", "${_rooms.length}"),
                          _buildSummaryCard("Occupied",
                              "${_rooms.where((r) => r.status == 'Checked In').length}"),
                          _buildSummaryCard("Available",
                              "${_rooms.where((r) => r.status == 'Available').length}"),
                          _buildSummaryCard("Cleaning",
                              "${_rooms.where((r) => r.status == 'Cleaning').length}"),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        _buildSummaryCard("Total Rooms", "${_rooms.length}"),
                        _buildSummaryCard("Occupied",
                            "${_rooms.where((r) => r.status == 'Checked In').length}"),
                        _buildSummaryCard("Available",
                            "${_rooms.where((r) => r.status == 'Available').length}"),
                        _buildSummaryCard("Cleaning",
                            "${_rooms.where((r) => r.status == 'Cleaning').length}"),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomList(double screenHeight) {
    return SizedBox(
      height: screenHeight * 0.5,
      child: ListView.builder(
        itemCount: _rooms.length,
        itemBuilder: (context, index) {
          final animation = Tween<Offset>(
            begin: Offset(1, 0),
            end: Offset(0, 0),
          ).animate(
            CurvedAnimation(
              parent: _controller,
              curve: Interval(
                (index / _rooms.length),
                1.0,
                curve: Curves.easeOut,
              ),
            ),
          );

          final isAvailable = _rooms[index].status == 'Available';
          final isCleaning = _rooms[index].status == 'Cleaning';
          final cardColor = isCleaning
              ? Colors.orange[100]
              : isAvailable
                  ? Colors.green[100]
                  : Colors.red[100];

          return SlideTransition(
            position: animation,
            child: Card(
              color: cardColor,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text("Room ${_rooms[index].id}"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Type: ${_rooms[index].type}"),
                    Text("Status: ${_rooms[index].status}"),
                    Text("Last Cleaned: ${_rooms[index].lastCleaned}"),
                    Text("Price Per Day: ${_rooms[index].pricePerDay}"),
                    Text("Bed Type: ${_rooms[index].bedType}"),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isAvailable)
                      IconButton(
                        icon: Icon(Icons.check_box),
                        onPressed: () => _checkInRoom(index),
                      ),
                    if (!isAvailable && !isCleaning)
                      IconButton(
                        icon: Icon(Icons.exit_to_app),
                        onPressed: () => _checkOutRoom(index),
                      ),
                    IconButton(
                      icon: Icon(Icons.cleaning_services),
                      onPressed: () => _cleanRoom(index),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
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
}
