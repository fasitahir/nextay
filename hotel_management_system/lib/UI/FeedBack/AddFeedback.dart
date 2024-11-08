import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String? Ip = dotenv.env['IP'];
final String? Port = dotenv.env['PORT'];
void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: FeedbackScreen(),
  ));
}

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  double _rating = 0;
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  String? _selectedType;

  final List<String> _feedbackTypes = ['Complaint', 'Suggestion', 'Compliment'];

  void _submitFeedback() async {
    final String customerName = _customerNameController.text;
    final String feedbackText = _feedbackController.text;
    final double rating = _rating;

    if (customerName.isNotEmpty &&
        feedbackText.isNotEmpty &&
        rating > 0 &&
        _selectedType != null) {
      final response = await http.post(
        Uri.parse('http://$Ip:$Port/feedback'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'customerName': customerName,
          'Feedback': feedbackText, // Ensure 'Feedback' is capitalized
          'Rating': rating.toInt(), // Ensure 'Rating' is capitalized
          'Type':
              _selectedType, // Type will be sent as a string (e.g., Complaint, Suggestion)
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback successfully submitted!')),
        );
        _feedbackController.clear();
        _customerNameController.clear();
        setState(() {
          _rating = 0;
          _selectedType = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: ${jsonDecode(response.body)['error']}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields correctly.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final blueGrey900 = Colors.blueGrey[900] ?? Colors.blueGrey[800]!;
    final blueGrey700 = Colors.blueGrey[700] ?? Colors.blueGrey[600]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback', style: TextStyle(color: Colors.white)),
        backgroundColor: blueGrey900,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeIn(
                duration: const Duration(seconds: 1),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Customer Name',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _customerNameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: blueGrey700),
                          ),
                          hintText: 'Enter your name',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              FadeIn(
                duration: const Duration(seconds: 1),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rate Your Experience',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      RatingBar.builder(
                        initialRating: _rating,
                        minRating: 1,
                        itemSize: 40,
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color:
                              _rating == 0 ? Colors.white : Colors.yellow[900],
                        ),
                        onRatingUpdate: (rating) {
                          setState(() {
                            _rating = rating;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              FadeIn(
                duration: const Duration(seconds: 1),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Feedback',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _feedbackController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: blueGrey700),
                          ),
                          hintText: 'Enter your feedback here',
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Type of Feedback',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: blueGrey700),
                          ),
                        ),
                        hint: const Text('Select Type'),
                        value: _selectedType,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedType = newValue;
                          });
                        },
                        items: _feedbackTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              FadeIn(
                duration: const Duration(seconds: 1),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _submitFeedback,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: blueGrey900),
                    child: const Text(
                      'Submit Feedback',
                      style: TextStyle(fontSize: 20),
                    ),
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
