import 'dart:convert';
//import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String? apiUrl = dotenv.env['IP'];
final String? apiPort = dotenv.env['PORT'];

// Room class definition
class Room {
  final int id;
  final String type;
  String status;
  final DateTime lastCleaned;
  final bool needsCleaning;
  final double pricePerDay;
  final double? roomArea;
  final int floorNumber;
  final int maxOccupancy;
  final String bedType;
  final DateTime lastMaintenanceDate;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;

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
    this.checkInTime,
    this.checkOutTime,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    final dateFormat = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'");
    return Room(
      id: json['id'],
      type: json['type'],
      status: json['status'],
      lastCleaned: dateFormat.parse(json['last_cleaned']),
      needsCleaning: json['needCleaning'],
      pricePerDay: json['price_per_day'],
      roomArea: json['room_area'],
      floorNumber: json['floor_number'],
      maxOccupancy: json['max_occupancy'],
      bedType: json['bed_type'],
      lastMaintenanceDate: dateFormat.parse(json['last_maintenance_date']),
      checkInTime: json['check_in_time'] != null
          ? dateFormat.parse(json['check_in_time'])
          : null,
      checkOutTime: json['check_out_time'] != null
          ? dateFormat.parse(json['check_out_time'])
          : null,
    );
  }
}

// StaffRoomsPage
class StaffRoomsPage extends StatefulWidget {
  const StaffRoomsPage({super.key});

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
      final response =
          await http.get(Uri.parse('http://$apiUrl:$apiPort/rooms'));

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

  void _checkInRoom(int index) async {
    try {
      final response = await http.put(
        Uri.parse('http://$apiUrl:$apiPort/rooms/${_rooms[index].id}/checkin'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        setState(() {
          _rooms[index].status = 'Occupied';
        });
      } else {
        throw Exception('Failed to check-in room');
      }
    } catch (error) {
      print('Error checking in room: $error');
    }
  }

  void _cleanRoom(int index) async {
    try {
      final response = await http.put(
        Uri.parse('http://$apiUrl:$apiPort/rooms/${_rooms[index].id}/clean'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        setState(() {
          _rooms[index].status = 'Available'; // or 'Cleaning'
        });
      } else {
        throw Exception('Failed to clean room');
      }
    } catch (error) {
      print('Error cleaning room: $error');
    }
  }

  void _checkOutRoom(int index) async {
    DateTime? checkInTime = _rooms[index].checkInTime;
    DateTime? checkOutTime = _rooms[index].checkOutTime;
    double totalBill = 0;

    if (checkInTime != null && checkOutTime != null) {
      final duration = checkOutTime.difference(checkInTime).inDays;
      totalBill = _rooms[index].pricePerDay * duration;
    } else {
      totalBill =
          _rooms[index].pricePerDay; // Default bill if times are unavailable
    }

    try {
      final response = await http.put(
        Uri.parse('http://$apiUrl:$apiPort/rooms/${_rooms[index].id}/checkout'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        setState(() {
          _rooms[index].status = 'Dirty'; // Change status to 'Dirty'
        });
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Checkout Bill'),
              content: Text(
                  'Total Bill for Room ${_rooms[index].id}: \$${totalBill.toStringAsFixed(2)}'), // Format to 2 decimal places
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        throw Exception('Failed to checkout room');
      }
    } catch (error) {
      print('Error during checkout: $error');
    }
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

          final cardColor = _getCardColor(_rooms[index].status);

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
                    Text(
                        "Price Per Day: \$${_rooms[index].pricePerDay.toStringAsFixed(2)}"), // Format price
                    Text("Bed Type: ${_rooms[index].bedType}"),
                  ],
                ),
                trailing: _buildTrailingButtons(index),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getCardColor(String status) {
    switch (status) {
      case 'Occupied':
        return Colors.red[100] ?? Colors.red; // Red for Occupied
      case 'Dirty':
        return Colors.yellow[100] ?? Colors.yellow; // Yellow for Dirty
      case 'Available':
        return Colors.green[100] ?? Colors.green; // Green for available
      default:
        return Colors.white; // Default color
    }
  }

  Widget _buildTrailingButtons(int index) {
    final isAvailable = _rooms[index].status == 'Available';
    final isCleaning = _rooms[index].status == 'Cleaning';
    final isToBeCleaned = _rooms[index].status == 'Dirty';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isAvailable)
          IconButton(
            icon: Icon(Icons.check_box),
            onPressed: () => _checkInRoom(index),
          ),
        if (!isAvailable && !isCleaning && isToBeCleaned)
          IconButton(
            icon: Icon(Icons.cleaning_services),
            onPressed: () => _cleanRoom(index),
          ),
        if (!isAvailable && !isCleaning && !isToBeCleaned)
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => _checkOutRoom(index),
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
                              "${_rooms.where((r) => r.status == 'Occupied').length}"),
                          _buildSummaryCard("Available",
                              "${_rooms.where((r) => r.status == 'Available').length}"),
                          _buildSummaryCard("Cleaning",
                              "${_rooms.where((r) => r.status == 'Dirty').length}"), // Change this to match the correct status
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        _buildSummaryCard("Total Rooms", "${_rooms.length}"),
                        _buildSummaryCard("Occupied",
                            "${_rooms.where((r) => r.status == 'Occupied').length}"),
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
