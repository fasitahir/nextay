import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String? Ip = dotenv.env['IP'];
final String? Port = dotenv.env['PORT'];

class FeedbackListScreen extends StatefulWidget {
  const FeedbackListScreen({super.key});

  @override
  _FeedbackListScreenState createState() => _FeedbackListScreenState();
}

class _FeedbackListScreenState extends State<FeedbackListScreen> {
  List<Map<String, dynamic>> feedbacks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFeedbacks();
  }

  Future<void> fetchFeedbacks() async {
    setState(() => isLoading = true); // Start loading
    try {
      final response =
          await http.get(Uri.parse('http://$Ip:$Port/get-feedbacks'));

      print('Fetching feedbacks...');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['feedbacks'];

        setState(() {
          feedbacks = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load feedbacks');
      }
    } catch (error) {
      print('Error fetching feedbacks: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load feedbacks: $error'),
        ),
      );
      setState(() => isLoading = false);
    }
  }

  String _getEmoji(double rating) {
    if (rating >= 4.5) return '😄';
    if (rating >= 3.5) return '😊';
    if (rating >= 2.5) return '😐';
    if (rating >= 1.5) return '😕';
    return '😢';
  }

  @override
  Widget build(BuildContext context) {
    final blueGrey900 = Colors.blueGrey[900] ?? Colors.blueGrey[800]!;
    final blueGrey700 = Colors.blueGrey[700] ?? Colors.blueGrey[600]!;
    final blueGrey400 = Colors.blueGrey[400] ?? Colors.blueGrey[300]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Feedback',
            style: TextStyle(color: Colors.white)),
        backgroundColor: blueGrey900,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : feedbacks.isEmpty
              ? const Center(child: Text('No feedbacks available'))
              : Container(
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
                      itemCount: feedbacks.length,
                      itemBuilder: (context, index) {
                        final feedback = feedbacks[index];

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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                        'Feedback Type: ${feedback['feedbackType']}',
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      RatingBar.builder(
                                        initialRating:
                                            feedback['rating'].toDouble(),
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
                                        _getEmoji(
                                            feedback['rating'].toDouble()),
                                        style: const TextStyle(fontSize: 30),
                                      ),
                                    ],
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
