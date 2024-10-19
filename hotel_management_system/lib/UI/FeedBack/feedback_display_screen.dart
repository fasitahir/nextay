import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:animate_do/animate_do.dart';
import 'feedback_storage.dart'; // Import the singleton storage

class FeedbackListScreen extends StatefulWidget {
  const FeedbackListScreen({super.key});

  @override
  _FeedbackListScreenState createState() => _FeedbackListScreenState();
}

class _FeedbackListScreenState extends State<FeedbackListScreen> {
  List<bool> reviewedStatus = [];

  @override
  void initState() {
    super.initState();
    // Initialize reviewed status for each feedback (default: false)
    reviewedStatus =
        List<bool>.filled(FeedbackStorage().feedbacks.length, false);
  }

  String _getEmoji(double rating) {
    if (rating >= 4.5) {
      return '😄';
    } else if (rating >= 3.5) {
      return '😊';
    } else if (rating >= 2.5) {
      return '😐';
    } else if (rating >= 1.5) {
      return '😕';
    } else {
      return '😢';
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedbackData = FeedbackStorage().feedbacks; // Access the feedbacks

    final blueGrey900 = Colors.blueGrey[900] ?? Colors.blueGrey[800]!;
    final blueGrey700 = Colors.blueGrey[700] ?? Colors.blueGrey[600]!;
    final blueGrey400 = Colors.blueGrey[400] ?? Colors.blueGrey[300]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Feedback',
            style: TextStyle(color: Colors.white)),
        backgroundColor: blueGrey900,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [blueGrey900, blueGrey700, blueGrey400],
          ),
        ),
        child: SafeArea(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: feedbackData.length,
            itemBuilder: (context, index) {
              final feedback = feedbackData[index];
              final bool isReviewed = reviewedStatus[index];

              return BounceInUp(
                duration: const Duration(milliseconds: 500),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  color: Colors.white.withOpacity(0.9),
                  shadowColor: Colors.black.withOpacity(0.2),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              feedback['customerName'],
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: blueGrey900,
                              ),
                            ),
                            Text(
                              feedback['feedbackType'],
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          feedback['feedback'],
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RatingBar.builder(
                              initialRating: feedback['rating'],
                              minRating: 1,
                              itemSize: 25,
                              ignoreGestures: true,
                              allowHalfRating: true,
                              itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) {},
                            ),
                            Text(
                              _getEmoji(feedback['rating']),
                              style: const TextStyle(fontSize: 30),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: isReviewed
                              ? null
                              : () {
                                  setState(() {
                                    reviewedStatus[index] = true;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Feedback by ${feedback['customerName']} marked as reviewed.'),
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isReviewed ? Colors.grey : blueGrey700,
                          ),
                          child: Text(
                            isReviewed ? 'Reviewed' : 'Mark as Reviewed',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
