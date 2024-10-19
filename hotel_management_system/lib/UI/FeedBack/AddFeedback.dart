import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:animate_do/animate_do.dart';
import 'feedback_storage.dart'; // Import the singleton storage

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

  void _submitFeedback() {
    final feedback = _feedbackController.text;
    final customerName = _customerNameController.text;
    final double currentRating = _rating;
    final String? feedbackType = _selectedType;

    if (customerName.isNotEmpty && feedback.isNotEmpty && currentRating > 0 && feedbackType != null) {
      // Store feedback in the singleton storage
      FeedbackStorage().addFeedback({
        'customerName': customerName,
        'feedback': feedback,
        'rating': currentRating,
        'feedbackType': feedbackType,
      });

      // Clear the fields
      _feedbackController.clear();
      _customerNameController.clear();
      setState(() {
        _rating = 0;
        _selectedType = null;
      });

      // Show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Feedback successfully submitted!'),
        ),
      );
    } else {
      // Show error message if fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide your name, feedback, rating, and type.'),
        ),
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
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      RatingBar.builder(
                        initialRating: _rating,
                        minRating: 1,
                        itemSize: 40,
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: _rating == 0 ? Colors.white : Colors.yellow[900],
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
              SlideInLeft(
                duration: const Duration(seconds: 1),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Feedback',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              const SizedBox(height: 32),
              Center(
                child: Bounce(
                  duration: const Duration(seconds: 1),
                  child: ElevatedButton(
                    onPressed: _submitFeedback,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blueGrey700,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text(
                      'Submit Feedback',
                      style: TextStyle(color: Colors.white),
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
