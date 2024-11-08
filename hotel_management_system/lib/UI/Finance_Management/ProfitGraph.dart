import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class ProfitCalculatorPage extends StatefulWidget {
  const ProfitCalculatorPage({super.key});

  @override
  _ProfitCalculatorPageState createState() => _ProfitCalculatorPageState();
}

class _ProfitCalculatorPageState extends State<ProfitCalculatorPage> {
  DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime endDate = DateTime.now();
  List<ProfitData> profitData = [];

  @override
  void initState() {
    super.initState();
    generateProfitData();
  }

  void generateProfitData() {
    Random random = Random();
    double baseProfit = 1000;
    profitData = List.generate(31, (index) {
      double fluctuation = (random.nextDouble() - 0.5) * 500;
      return ProfitData(
        date: startDate.add(Duration(days: index)),
        profit: baseProfit + fluctuation + (index * 50),
      );
    });
  }

  double calculateTotalProfit() {
    return profitData
        .where((data) =>
            data.date.isAfter(startDate.subtract(Duration(days: 1))) &&
            data.date.isBefore(endDate.add(Duration(days: 1))))
        .map((data) => data.profit)
        .fold(0, (prev, amount) => prev + amount);
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
    );
    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
        generateProfitData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double totalProfit = calculateTotalProfit();

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Colors.blueGrey[900]!,
              Colors.blueGrey[700]!,
              Colors.blueGrey[400]!,
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
                  "Profit Calculator",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Expanded(
              child: Container(
                width: screenWidth * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Period: ${DateFormat('yyyy-MM-dd').format(startDate)} to ${DateFormat('yyyy-MM-dd').format(endDate)}',
                            style: TextStyle(fontSize: 16),
                          ),
                          ElevatedButton(
                            onPressed: () => _selectDateRange(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey[600],
                            ),
                            child: Text('Select Period',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Total Profit: \$${totalProfit.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      Expanded(
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(show: true),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    if (value % 5 == 0) {
                                      return Text(DateFormat('MM/dd').format(
                                          startDate.add(
                                              Duration(days: value.toInt()))));
                                    }
                                    return const Text('');
                                  },
                                  reservedSize: 25,
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      '\$${value.toInt()}', // Properly formatting the y-axis profit labels
                                      style: TextStyle(
                                        color: Colors
                                            .black, // Make it more readable
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                  reservedSize: 40,
                                ),
                              ),
                              topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(
                                  color: const Color(0xff37434d), width: 1),
                            ),
                            minX: 0,
                            maxX: profitData.length.toDouble() - 1,
                            minY: profitData
                                    .map((data) => data.profit)
                                    .reduce(min) *
                                0.9, // Adjust dynamic range
                            maxY: profitData
                                    .map((data) => data.profit)
                                    .reduce(max) *
                                1.1, // Adjust dynamic range
                            lineBarsData: [
                              LineChartBarData(
                                spots: profitData.asMap().entries.map((entry) {
                                  return FlSpot(
                                      entry.key.toDouble(), entry.value.profit);
                                }).toList(),
                                isCurved: true,
                                color: Colors.blue,
                                barWidth: 3,
                                dotData: FlDotData(show: false),
                                belowBarData: BarAreaData(
                                    show: true,
                                    color: Colors.blue.withOpacity(0.2)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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

class ProfitData {
  final DateTime date;
  final double profit;

  ProfitData({required this.date, required this.profit});
}
