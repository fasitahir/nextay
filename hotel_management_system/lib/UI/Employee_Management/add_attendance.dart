import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart'; // For formatting the date

class MarkAttendance extends StatefulWidget {
  const MarkAttendance({super.key});

  @override
  _MarkAttendanceState createState() => _MarkAttendanceState();
}

class _MarkAttendanceState extends State<MarkAttendance>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Dummy data for employee list
  final List<Employee> employees = List.generate(
    10,
    (index) => Employee(
      id: index,
      firstName: 'Employee',
      lastName: '${index + 1}',
      attendanceStatus: AttendanceStatus.present,
    ),
  );

  // Get today's date
  final String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

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

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    // ignore: unused_local_variable
    bool isWeb = screenWidth > 800;

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
                  child: Align(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const Text(
                          "Mark Employees Attendance",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        // Display the date
                        Text(
                          "Date: $todayDate",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ],
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
                      SizedBox(height: screenHeight * 0.02),
                      SizedBox(
                        height: screenHeight * 0.55,
                        child: FadeTransition(
                          opacity: _controller,
                          child: ListView.builder(
                            itemCount: employees.length,
                            itemBuilder: (context, index) {
                              final animation = Tween<Offset>(
                                begin: const Offset(1, 0),
                                end: const Offset(0, 0),
                              ).animate(
                                CurvedAnimation(
                                  parent: _controller,
                                  curve: Interval(
                                    (index / employees.length),
                                    1.0,
                                    curve: Curves.easeOut,
                                  ),
                                ),
                              );

                              // Change color based on attendance status
                              Color cardColor = Colors.white;
                              if (employees[index].attendanceStatus ==
                                  AttendanceStatus.absent) {
                                cardColor = Colors.red[100]!;
                              } else if (employees[index].attendanceStatus ==
                                  AttendanceStatus.late) {
                                cardColor = Colors.yellow[100]!;
                              }

                              return SlideTransition(
                                position: animation,
                                child: Card(
                                  color: cardColor,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    leading: Icon(Icons.person,
                                        color: Colors.blueGrey[900]),
                                    title: Text(
                                        "${employees[index].firstName} ${employees[index].lastName}"),
                                    subtitle: Text(
                                        "Status: ${employees[index].attendanceStatus.name}"),
                                    trailing: DropdownButton<AttendanceStatus>(
                                      value: employees[index].attendanceStatus,
                                      onChanged: (AttendanceStatus? newValue) {
                                        setState(() {
                                          employees[index].attendanceStatus =
                                              newValue!;
                                        });
                                      },
                                      items: AttendanceStatus.values
                                          .map((AttendanceStatus status) {
                                        return DropdownMenuItem<
                                            AttendanceStatus>(
                                          value: status,
                                          child: Text(status
                                              .toString()
                                              .split('.')
                                              .last),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      MaterialButton(
                        onPressed: () {
                          // Show success message
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Attendance successfully marked!"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        height: 50,
                        color: Colors.blueGrey[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Center(
                          child: Text(
                            "Submit Attendance",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
    );
  }
}

class Employee {
  final int id;
  final String firstName;
  final String lastName;
  AttendanceStatus attendanceStatus;

  Employee({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.attendanceStatus,
  });
}

enum AttendanceStatus { present, absent, late }

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MarkAttendance(),
  ));
}
