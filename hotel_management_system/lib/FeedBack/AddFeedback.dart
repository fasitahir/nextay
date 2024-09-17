import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// ignore: unused_import
import 'feedback_display_screen.dart';
import 'package:animate_do/animate_do.dart';

void main() {
  runApp(const MaterialApp(
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

  void _submitFeedback() {
    final feedback = _feedbackController.text;
    if (feedback.isNotEmpty && _rating > 0) {
      // Clear the fields
      _feedbackController.clear();
      setState(() {
        _rating = 0;
      });

      // Navigate to the FeedbackDisplayScreen with the feedback details
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => FeedbackDisplayScreen(
      //       feedback: feedback,
      //       rating: _rating,
      //     ),
    } else {
      // Show an error message if fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide feedback and rating.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final blueGrey900 = Colors.blueGrey[900] ?? Colors.blueGrey[800]!;
    final blueGrey700 = Colors.blueGrey[700] ?? Colors.blueGrey[600]!;
    final blueGrey400 = Colors.blueGrey[400] ?? Colors.blueGrey[300]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback', style: TextStyle(color: Colors.white)),
        backgroundColor: blueGrey900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeIn(
              duration: const Duration(seconds: 1),
              child: Container(
                margin: const EdgeInsets.only(bottom: 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rate Your Experience',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    RatingBar.builder(
                      initialRating: _rating,
                      minRating: 1,
                      itemSize: 40,
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: _rating == 0
                            ? Colors.white
                            : Colors.yellow[
                                900], // Change to yellow when rating is given
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
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  child: const Text(
                    'Submit Feedback',
                    style: TextStyle(color: Colors.white),
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
