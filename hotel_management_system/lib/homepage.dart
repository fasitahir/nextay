import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:hotel_management_system/Employee_Management/emolyee_shift.dart';
import 'package:hotel_management_system/Finance_Management/BillCalculator.dart';
import 'package:hotel_management_system/Employee_Management/add_employee.dart';
import 'package:hotel_management_system/Employee_Management/update_employee.dart';
import 'package:hotel_management_system/FeedBack/feedback_display_screen.dart';
import 'package:hotel_management_system/FeedBack/AddFeedback.dart';
import 'package:hotel_management_system/Room_Management/rooms.dart';

class Home extends StatelessWidget {
  final String email;

  const Home({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    double screenheight = MediaQuery.of(context).size.height;
    double screenwidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, colors: [
          Colors.blueGrey[900] ?? Colors.blueGrey,
          Colors.blueGrey[700] ?? Colors.blueGrey,
          Colors.blueGrey[400] ?? Colors.blueGrey,
        ])),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: screenheight * 0.07,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: screenheight * 0.01,
                  horizontal: screenwidth * 0.03),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        FadeInUp(
                            duration: const Duration(milliseconds: 1000),
                            child: const Text(
                              "Welcome Back",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 40),
                            )),
                        SizedBox(
                          height: screenheight * 0.01,
                        ),
                        FadeInUp(
                            duration: const Duration(milliseconds: 1300),
                            child: Text(
                              email,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18),
                            )),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: screenwidth * 0.02),
                    child: FadeInUp(
                      duration: const Duration(milliseconds: 1600),
                      child: Container(
                        height: 120,
                        width: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: const DecorationImage(
                            image: AssetImage('images/hotel.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenheight * 0.05),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(
                    vertical: screenheight * 0.00,
                    horizontal: screenwidth * 0.00),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    )),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: screenheight * 0.02,
                      horizontal: screenwidth * 0.05),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = (constraints.maxWidth > 1200)
                          ? 4
                          : (constraints.maxWidth > 800)
                              ? 2
                              : 2;

                      return GridView.count(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio:
                            (constraints.maxWidth > 800) ? 3.3 : 1.4,
                        children: <Widget>[
                          _buildFeatureBox(
                            context,
                            'Manage Employees',
                            [
                              'Add Employee',
                              'Update Employee',
                              "Employee's Shift"
                            ],
                            Icons.person,
                          ),
                          _buildFeatureBox(
                            context,
                            'Manage Finance',
                            [
                              'Bill Calculator',
                              'Profit Calculator',
                              'Profit Graph'
                            ],
                            Icons.money_sharp,
                          ),
                          _buildFeatureBox(
                            context,
                            'Manage Rooms',
                            [
                              'Add Room',
                              'Delete Room',
                              'View Rooms',
                              'Search Rooms'
                            ],
                            Icons.hotel,
                          ),
                          _buildFeatureBox(
                            context,
                            'Manage Feedback',
                            [
                              'View Feedback',
                              'Add Feedback',
                              'Delete Feedback'
                            ],
                            Icons.feedback,
                          ),
                        ],
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

  Widget _buildFeatureBox(BuildContext context, String title,
      List<String> useCases, IconData icon) {
    if (title == 'Manage Rooms') {
      // Special case for Manage Rooms, without popup
      return FadeInUp(
        duration: const Duration(milliseconds: 1000),
        child: GestureDetector(
          onTap: () {
            String email = "Alishbasheikh@gmail.com";
            String password = "alishba";
            // Navigate to the Manage Rooms page when clicked
            Navigator.push(
              context,
              MaterialPageRoute(
                // Replace with your ManageRooms page widget

                builder: (context) => Rooms(email: email, password: password),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueGrey[300] ?? Colors.blueGrey,
                  blurRadius: 10,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  icon,
                  color: Colors.blueGrey[700],
                  size: 30,
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blueGrey[700],
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Default behavior with PopupMenuButton for other sections
      return FadeInUp(
        duration: const Duration(milliseconds: 1000),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.blueGrey[300] ?? Colors.blueGrey,
                blurRadius: 10,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                color: Colors.blueGrey[700],
                size: 30,
              ),
              const SizedBox(height: 10),
              PopupMenuButton<String>(
                onSelected: (value) {
                  // Handle navigation for each use case
                  if (value == 'Bill Calculator') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Billcalculator()),
                    );
                  }
                  if (value == 'Add Employee') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddEmployee()),
                    );
                  }
                  if (value == 'Update Employee') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const EmployeeUpdate()),
                    );
                  }
                  if (value == "Employee's Shift") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const EmployeeShift()),
                    );
                  }
                  if (value == "View Feedback") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FeedbackDisplayScreen(
                              feedback: "hello", rating: 4)),
                    );
                  }
                  if (value == "Add Feedback") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FeedbackScreen()),
                    );
                  }
                },
                itemBuilder: (context) {
                  return useCases.map((useCase) {
                    return PopupMenuItem(
                      value: useCase,
                      child: Text(useCase),
                    );
                  }).toList();
                },
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blueGrey[700],
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}

// Dummy ManageRoomsPage class for demonstration
