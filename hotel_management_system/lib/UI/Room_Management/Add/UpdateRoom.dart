import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:animate_do/animate_do.dart';

// Room class definition
class Room {
  final int id;
  final String name;
  final String type;
  String status;
  DateTime lastCleaned;
  bool needsCleaning;
  double pricePerDay;
  double? roomArea;
  int floorNumber;
  int maxOccupancy;
  String bedType;
  DateTime lastMaintenanceDate;

  Room({
    required this.id,
    required this.name,
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
}

// Manager Rooms Page
class ManagerRoomsPage extends StatefulWidget {
  const ManagerRoomsPage({super.key});

  @override
  _ManagerRoomsPageState createState() => _ManagerRoomsPageState();
}

class _ManagerRoomsPageState extends State<ManagerRoomsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final List<Room> _rooms = List.generate(
      10,
      (index) => Room(
          id: index,
          name: 'Room ${index + 1}',
          type: 'Suite',
          status: 'Available',
          lastCleaned: DateTime.now(),
          needsCleaning: false,
          pricePerDay: 100.0,
          roomArea: 30.0,
          floorNumber: 1,
          maxOccupancy: 2,
          bedType: 'Queen',
          lastMaintenanceDate: DateTime.now()));

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    // Start animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addRoom() {
    String roomName = '';
    String roomType = '';
    String roomStatus = 'Available';
    double pricePerDay = 0.0;
    double? roomArea;
    int floorNumber = 1;
    int maxOccupancy = 1;
    String bedType = '';
    // ignore: unused_local_variable
    DateTime lastMaintenanceDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Room'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Room Name'),
                onChanged: (value) {
                  roomName = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Room Type'),
                onChanged: (value) {
                  roomType = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Price Per Day'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  pricePerDay = double.tryParse(value) ?? 0.0;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Room Area (optional)'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  roomArea = value.isNotEmpty ? double.tryParse(value) : null;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Floor Number'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  floorNumber = int.tryParse(value) ?? 1;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Max Occupancy'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  maxOccupancy = int.tryParse(value) ?? 1;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Bed Type'),
                onChanged: (value) {
                  bedType = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (roomName.isNotEmpty && roomType.isNotEmpty) {
                  setState(() {
                    _rooms.add(Room(
                      id: _rooms.length,
                      name: roomName,
                      type: roomType,
                      status: roomStatus,
                      lastCleaned: DateTime.now(),
                      needsCleaning: false,
                      pricePerDay: pricePerDay,
                      roomArea: roomArea,
                      floorNumber: floorNumber,
                      maxOccupancy: maxOccupancy,
                      bedType: bedType,
                      lastMaintenanceDate: DateTime.now(),
                    ));
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
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

  void _editRoom(int index) {
    String roomName = _rooms[index].name;
    String roomType = _rooms[index].type;
    double pricePerDay = _rooms[index].pricePerDay;
    double? roomArea = _rooms[index].roomArea;
    int floorNumber = _rooms[index].floorNumber;
    int maxOccupancy = _rooms[index].maxOccupancy;
    String bedType = _rooms[index].bedType;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Room'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: roomName),
                decoration: InputDecoration(labelText: 'Room Name'),
                onChanged: (value) {
                  roomName = value;
                },
              ),
              TextField(
                controller: TextEditingController(text: roomType),
                decoration: InputDecoration(labelText: 'Room Type'),
                onChanged: (value) {
                  roomType = value;
                },
              ),
              TextField(
                controller: TextEditingController(text: pricePerDay.toString()),
                decoration: InputDecoration(labelText: 'Price Per Day'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  pricePerDay = double.tryParse(value) ?? 0.0;
                },
              ),
              TextField(
                controller: TextEditingController(text: roomArea?.toString()),
                decoration: InputDecoration(labelText: 'Room Area (optional)'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  roomArea = value.isNotEmpty ? double.tryParse(value) : null;
                },
              ),
              TextField(
                controller: TextEditingController(text: floorNumber.toString()),
                decoration: InputDecoration(labelText: 'Floor Number'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  floorNumber = int.tryParse(value) ?? 1;
                },
              ),
              TextField(
                controller:
                    TextEditingController(text: maxOccupancy.toString()),
                decoration: InputDecoration(labelText: 'Max Occupancy'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  maxOccupancy = int.tryParse(value) ?? 1;
                },
              ),
              TextField(
                controller: TextEditingController(text: bedType),
                decoration: InputDecoration(labelText: 'Bed Type'),
                onChanged: (value) {
                  bedType = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (roomName.isNotEmpty && roomType.isNotEmpty) {
                  setState(() {
                    _rooms[index] = Room(
                      id: _rooms[index].id,
                      name: roomName,
                      type: roomType,
                      status: _rooms[index].status,
                      lastCleaned: _rooms[index].lastCleaned,
                      needsCleaning: _rooms[index].needsCleaning,
                      pricePerDay: pricePerDay,
                      roomArea: roomArea,
                      floorNumber: floorNumber,
                      maxOccupancy: maxOccupancy,
                      bedType: bedType,
                      lastMaintenanceDate: DateTime.now(),
                    );
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Save'),
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

  void _deleteRoom(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Room'),
          content: Text('Are you sure you want to delete this room?'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _rooms.removeAt(index);
                });
                Navigator.of(context).pop();
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('No'),
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
      appBar: AppBar(
        title: Text('Manager Room Management',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueGrey[900],
        iconTheme: IconThemeData(color: Colors.white),
      ),
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.04),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                child: FadeTransition(
                  opacity: _controller,
                  child: const Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Room Management Overview",
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
              Container(
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                      horizontal: screenWidth * 0.03),
                  child: Column(
                    children: [
                      FadeTransition(
                        opacity: _controller,
                        child: ListView.builder(
                          itemCount: _rooms.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
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

                            final isAvailable =
                                _rooms[index].status == 'Available';
                            final isCleaning =
                                _rooms[index].status == 'Cleaning';
                            final cardColor = isCleaning
                                ? Colors.orange[100]
                                : isAvailable
                                    ? const Color.fromARGB(255, 135, 194, 211)
                                    : Colors.red[100];

                            return SlideTransition(
                              position: animation,
                              child: Card(
                                color: cardColor,
                                margin: EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  leading: Icon(Icons.hotel,
                                      color: Colors.blueGrey[900]),
                                  title: Text(_rooms[index].name),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Type: ${_rooms[index].type}"),
                                      Text("Status: ${_rooms[index].status}"),
                                      Text(
                                          "Last Cleaned: ${_rooms[index].lastCleaned}"),
                                      Text(
                                          "Price Per Day: ${_rooms[index].pricePerDay}"),
                                      Text(
                                          "Bed Type: ${_rooms[index].bedType}"),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit,
                                            color: Colors.blueGrey[900]),
                                        onPressed: () => _editRoom(index),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () => _deleteRoom(index),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addRoom,
        backgroundColor: Colors.blueGrey[900],
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
