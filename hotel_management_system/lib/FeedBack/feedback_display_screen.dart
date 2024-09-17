import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart'; // Import Animate Do package

class FeedbackDisplayScreen extends StatelessWidget {
  final String feedback;
  final double rating;

  const FeedbackDisplayScreen(
      {super.key, required this.feedback, required this.rating});

  // Method to return an emoji based on the rating
  String _getEmoji(double rating) {
    if (rating >= 4.5) {
      return '😄'; // Excellent
    } else if (rating >= 3.5) {
      return '😊'; // Good
    } else if (rating >= 2.5) {
      return '😐'; // Neutral
    } else if (rating >= 1.5) {
      return '😕'; // Disappointed
    } else {
      return '😢'; // Very bad
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blueGrey[900] ?? Colors.blueGrey,
              Colors.blueGrey[700] ?? Colors.blueGrey,
              Colors.blueGrey[400] ?? Colors.blueGrey,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Large heading
                  FadeInDown(
                    duration: const Duration(seconds: 1),
                    child: Text(
                      "Customer's Feedback",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            offset: const Offset(2.0, 2.0),
                            blurRadius: 3.0,
                            color: Colors.black.withOpacity(0.4),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 40), // Space between heading and box

                  // Feedback box
                  ZoomIn(
                    duration: const Duration(seconds: 1),
                    child: Container(
                      padding: const EdgeInsets.all(24.0),
                      margin: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[100],
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            spreadRadius: 3,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FadeInDown(
                            duration: const Duration(seconds: 1),
                            child: Text(
                              "Your Rating",
                              style: GoogleFonts.poppins(
                                color: Colors.blueGrey[900],
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ZoomIn(
                            duration: const Duration(seconds: 1),
                            child: Column(
                              children: [
                                Text(
                                  _getEmoji(rating),
                                  style: const TextStyle(
                                    fontSize: 50,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Rating: ${rating.toStringAsFixed(1)}",
                                  style: GoogleFonts.montserrat(
                                    color: Colors.blueGrey[900],
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                          FadeInUp(
                            duration: const Duration(seconds: 1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blueGrey[900]!,
                                    Colors.blueGrey[700]!,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Text(
                                "Feedback",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  shadows: [
                                    Shadow(
                                      offset: const Offset(2.0, 2.0),
                                      blurRadius: 3.0,
                                      color: Colors.black.withOpacity(0.4),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SlideInUp(
                            duration: const Duration(seconds: 1),
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[200],
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Text(
                                feedback,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  color: Colors.blueGrey[900],
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
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
        ),
      ),
    );
  }
}
