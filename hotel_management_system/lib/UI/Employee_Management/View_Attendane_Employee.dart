import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class ViewAttendanceForEmployee extends StatefulWidget {
  final Employee employee;

  const ViewAttendanceForEmployee({super.key, required this.employee});

  @override
  _ViewAttendanceForEmployeeState createState() =>
      _ViewAttendanceForEmployeeState();
}

class _ViewAttendanceForEmployeeState extends State<ViewAttendanceForEmployee> {
  // Simulated attendance data for the employee
  final List<Map<String, dynamic>> attendanceRecords = List.generate(
    10,
    (index) => {
      'date': DateTime.now().subtract(Duration(days: index)),
      'status': AttendanceStatus.values[index % 3],
    },
  );

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
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Your Attendance",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),

            // White box with Card layout
            Expanded(
              child: Container(
                width: screenWidth * 0.9, // 90% of screen width
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
                  child: ListView.builder(
                    itemCount: attendanceRecords.length,
                    itemBuilder: (context, index) {
                      final record = attendanceRecords[index];
                      final date =
                          DateFormat('yyyy-MM-dd').format(record['date']);
                      final status =
                          record['status'].toString().split('.').last;

                      // Status based card color
                      Color cardColor = Colors.white;
                      if (record['status'] == AttendanceStatus.absent) {
                        cardColor = Colors.red[100]!;
                      } else if (record['status'] == AttendanceStatus.late) {
                        cardColor = Colors.yellow[100]!;
                      }

                      return Card(
                        color: cardColor,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.date_range,
                            color: Colors.blueGrey[700],
                          ),
                          title: Text("Date: $date"),
                          subtitle: Text("Status: $status"),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
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
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ViewAttendanceForEmployee(
      employee: Employee(
        id: 1,
        firstName: 'John',
        lastName: 'Doe',
        attendanceStatus: AttendanceStatus.present,
      ),
    ),
  ));
}
