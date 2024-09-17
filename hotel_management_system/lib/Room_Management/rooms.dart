import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class Rooms extends StatefulWidget {
  final String email;
  final String password;

  const Rooms({super.key, required this.email, required this.password});

  @override
  _RoomsState createState() => _RoomsState();
}

class _RoomsState extends State<Rooms> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Room> _rooms = List.generate(
      10,
      (index) => Room(
          id: index,
          name: 'Room ${index + 1}',
          type: 'Suite',
          status: 'Available',
          lastCleaned: DateTime.now(),
          needsCleaning: false));

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addRoom() async {
    final Room? newRoom = await showDialog<Room>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Room'),
          content: RoomForm(),
        );
      },
    );

    if (newRoom != null) {
      setState(() {
        _rooms.add(newRoom);
      });
    }
  }

  void _editRoom(int index) async {
    final Room? updatedRoom = await showDialog<Room>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Room ${_rooms[index].name}'),
          content: RoomForm(
            initialName: _rooms[index].name,
            initialType: _rooms[index].type,
            initialStatus: _rooms[index].status,
            initialLastCleaned: _rooms[index].lastCleaned,
          ),
        );
      },
    );

    if (updatedRoom != null) {
      setState(() {
        _rooms[index] = updatedRoom;
      });
    }
  }

  void _checkInRoom(int index) {
    setState(() {
      _rooms[index].status = 'Checked In';
      _rooms[index].needsCleaning = false;
    });
  }

  void _checkOutRoom(int index) {
    setState(() {
      _rooms[index].status = 'Cleaning';
      _rooms[index].lastCleaned = DateTime.now();
      _rooms[index].needsCleaning = true;
    });
  }

  void _cleanRoom(int index) {
    setState(() {
      _rooms[index].status = 'Available';
      _rooms[index].needsCleaning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWeb = screenWidth > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Room Management Page",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Add search functionality here
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              // Add filter functionality here
            },
          ),
        ],
        backgroundColor: Colors.blueGrey[900],
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
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
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.03,
                  horizontal: screenWidth * 0.03,
                ),
                child: FadeTransition(
                  opacity: _controller,
                  child: const Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Room Summary",
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
                                    _buildSummaryCard(
                                        "Total Rooms", "${_rooms.length}"),
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
                                  _buildSummaryCard(
                                      "Total Rooms", "${_rooms.length}"),
                                  _buildSummaryCard("Occupied",
                                      "${_rooms.where((r) => r.status == 'Checked In').length}"),
                                  _buildSummaryCard("Available",
                                      "${_rooms.where((r) => r.status == 'Available').length}"),
                                  _buildSummaryCard("Cleaning",
                                      "${_rooms.where((r) => r.status == 'Cleaning').length}"),
                                ],
                              ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      SizedBox(
                        height: screenHeight * 0.5,
                        child: FadeTransition(
                          opacity: _controller,
                          child: ListView.builder(
                            itemCount: _rooms.length,
                            itemBuilder: (context, index) {
                              final animation = Tween<Offset>(
                                begin: const Offset(1, 0),
                                end: const Offset(0, 0),
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
                                      ? Colors.green[100]
                                      : Colors.red[100];

                              return SlideTransition(
                                position: animation,
                                child: Card(
                                  color: cardColor,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
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
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (isAvailable)
                                          IconButton(
                                            icon: Icon(Icons.check_circle,
                                                color: Colors.blueGrey[900]),
                                            onPressed: () =>
                                                _checkInRoom(index),
                                          ),
                                        if (isCleaning)
                                          IconButton(
                                            icon: Icon(Icons.cleaning_services,
                                                color: Colors.blueGrey[900]),
                                            onPressed: () => _cleanRoom(index),
                                          ),
                                        if (_rooms[index].status !=
                                                'Available' &&
                                            !isCleaning)
                                          IconButton(
                                            icon: Icon(Icons.cancel,
                                                color: Colors.blueGrey[900]),
                                            onPressed: () =>
                                                _checkOutRoom(index),
                                          ),
                                        IconButton(
                                          icon: Icon(Icons.edit,
                                              color: Colors.blueGrey[900]),
                                          onPressed: () => _editRoom(index),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      )
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

  Widget _buildSummaryCard(String title, String value) {
    return Card(
      elevation: 10,
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[900],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[900],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Room {
  final int id;
  String name;
  String type;
  String status;
  DateTime lastCleaned;
  bool needsCleaning;

  Room(
      {required this.id,
      required this.name,
      required this.type,
      required this.status,
      required this.lastCleaned,
      required this.needsCleaning});
}

class RoomForm extends StatefulWidget {
  final String? initialName;
  final String? initialType;
  final String? initialStatus;
  final DateTime? initialLastCleaned;

  const RoomForm(
      {super.key,
      this.initialName,
      this.initialType,
      this.initialStatus,
      this.initialLastCleaned});

  @override
  _RoomFormState createState() => _RoomFormState();
}

class _RoomFormState extends State<RoomForm> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _type;
  late String _status;
  late DateTime _lastCleaned;

  @override
  void initState() {
    super.initState();
    _name = widget.initialName ?? '';
    _type = widget.initialType ?? 'Suite';
    _status = widget.initialStatus ?? 'Available';
    _lastCleaned = widget.initialLastCleaned ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            initialValue: _name,
            decoration: const InputDecoration(labelText: 'Room Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter room name';
              }
              return null;
            },
            onSaved: (value) {
              if (value != null) {
                _name = value;
              }
            },
          ),
          TextFormField(
            initialValue: _type,
            decoration: const InputDecoration(labelText: 'Room Type'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter room type';
              }
              return null;
            },
            onSaved: (value) {
              if (value != null) {
                _type = value;
              }
            },
          ),
          DropdownButtonFormField<String>(
            value: _status,
            decoration: const InputDecoration(labelText: 'Room Status'),
            items: ['Available', 'Checked In', 'Cleaning'].map((status) {
              return DropdownMenuItem<String>(
                value: status,
                child: Text(status),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _status = value;
                });
              }
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                Navigator.of(context).pop(Room(
                  id: DateTime.now().millisecondsSinceEpoch,
                  name: _name,
                  type: _type,
                  status: _status,
                  lastCleaned: _lastCleaned,
                  needsCleaning: _status == 'Cleaning',
                ));
              }
            },
            child: const Text(
              'Save Room',
              style: TextStyle(
                color: Color.fromARGB(255, 16, 82, 169),
                fontSize: 16.0, // You can adjust the font size if needed
              ),
            ),
          ),
        ],
      ),
    );
  }
}
