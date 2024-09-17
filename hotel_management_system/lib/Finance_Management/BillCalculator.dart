import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

class Billcalculator extends StatefulWidget {
  const Billcalculator({super.key});

  @override
  _Bill createState() => _Bill();
}

class _Bill extends State<Billcalculator> {
  final TextEditingController roomController = TextEditingController();
  String totalBill = '';

  void calculateBill() {
    // Example calculation logic; replace with your actual billing logic
    // For demonstration purposes, let's assume a fixed rate of 100 per room
    int roomCount = int.tryParse(roomController.text) ?? 0;
    double billAmount = roomCount * 100.0;
    setState(() {
      totalBill = 'Total Bill: ${billAmount.toStringAsFixed(2)}';
    });
  }

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  BounceInDown(
                      duration: const Duration(milliseconds: 1000),
                      child: const Text(
                        "Bill Calculator",
                        style: TextStyle(color: Colors.white, fontSize: 40),
                      )),
                  SizedBox(
                    height: screenheight * 0.01,
                  ),
                ],
              ),
            ),
            SizedBox(height: screenheight * 0.07),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(
                    vertical: screenheight * 0.03,
                    horizontal: screenwidth * 0.03),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    )),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: screenheight * 0.01,
                      horizontal: screenwidth * 0.03),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: screenheight * 0.08,
                      ),
                      FlipInX(
                          duration: const Duration(milliseconds: 1400),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.blueGrey[200] ??
                                          Colors.blueGrey,
                                      blurRadius: 20,
                                      offset: const Offset(0, 10))
                                ]),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: Colors.grey.shade200))),
                                  child: TextField(
                                    controller: roomController,
                                    decoration: const InputDecoration(
                                        hintText:
                                            "Enter Id or Room number for billing",
                                        hintStyle:
                                            TextStyle(color: Colors.grey),
                                        border: InputBorder.none),
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                SizedBox(
                                  height: screenheight * 0.03,
                                ),
                                ElevatedButton(
                                  onPressed: calculateBill,
                                  child: const Text('Calculate Bill'),
                                ),
                                SizedBox(
                                  height: screenheight * 0.02,
                                ),
                                if (totalBill.isNotEmpty)
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                        vertical: screenheight * 0.02),
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.blueGrey[200],
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 30,
                                          offset: Offset(0, 10),
                                        )
                                      ],
                                    ),
                                    child: Text(
                                      totalBill,
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueGrey[900]),
                                    ),
                                  ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
