import 'dart:convert'; // For jsonEncode and jsonDecode

import 'package:Daeufle/constants/colors.dart';
import 'package:Daeufle/screens/courses.dart'; // Assuming this import is correct
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import "package:http/http.dart"
    as http; // Make sure http package is in pubspec.yaml

class AnalyzeResults extends StatefulWidget {
  final List<Map<String, String>> selectedAnswers;

  const AnalyzeResults({super.key, required this.selectedAnswers});

  @override
  State<AnalyzeResults> createState() => _AnalyzeResultsState();
}

class _AnalyzeResultsState extends State<AnalyzeResults>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late Future<Map<String, dynamic>> _resultsFuture;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _controller.repeat();

    _resultsFuture = _sendAnswersToBackend();
  }

  Future<Map<String, dynamic>> _sendAnswersToBackend() async {
    try {
      final Uri apiUrl = Uri.parse(
        "https://daufle-server.onrender.com/api/quiz/analyze",
      ); // Example backend URL
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not logged in. Cannot analyze quiz results.");
      }
      final String? idToken = await user.getIdToken();
      if (idToken == null) {
        print("id toke is null");
        throw Exception(
          "Failed to get user ID token. Cannot analyze quiz results.",
        );
      }
      final response = await http.post(
        apiUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode(widget.selectedAnswers),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to load results from backend: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to connect to backend or process results: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Results AI Analysis"),
        centerTitle: true,
        leading: Image.asset("assets/images/tbc-logo.png"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0), // Consistent padding
        child: Center(
          child: FutureBuilder<Map<String, dynamic>>(
            // Explicitly define Future type
            future: _resultsFuture, // Use the initialized future
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Analyzing Results...',
                      style: TextStyle(
                        fontSize: 30,
                        color: AppColors.purpleAccent,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    Lottie.asset(
                      "assets/analyze-animation.json",
                      controller: _controller,
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _resultsFuture =
                              _sendAnswersToBackend(); // Retry the API call
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                );
              } else if (snapshot.hasData) {
                final Map<String, dynamic> data = snapshot.data!;

                print('suitable Courses: ${data["suitableCourses"]}');

                // FIX: Explicitly cast to List<dynamic> and then filter/map
                final List<Map<String, dynamic>> coursesData =
                    (data["suitableCourses"] as List<dynamic>?)
                        ?.whereType<
                          Map<String, dynamic>
                        >() // Filter out non-map elements
                        .map((e) => e as Map<String, dynamic>)
                        .toList() ??
                    [];

                final String careerRecommendationText =
                    (data["careerRecommendation"] is String)
                    ? data["careerRecommendation"] as String
                    : (data["careerRecommendation"]?.toString() ??
                          "No career recommendation found.");
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SummaryLogo(),
                    const SizedBox(height: 24),
                    Text(
                      careerRecommendationText,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => Courses(
                              coursesData: coursesData,
                              careerRecommendation: careerRecommendationText,
                            ),
                          ),
                        );
                      },
                      child: const Text('See Recommended Courses'),
                    ),
                  ],
                );
              } else {
                return const Center(child: Text('No results to display.'));
              }
            },
          ),
        ),
      ),
    );
  }
}

class SummaryLogo extends StatelessWidget {
  const SummaryLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppColors.purpleAccent,
            Colors.blueAccent,
            Colors.cyanAccent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.purpleAccent.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Icon(
        Icons.auto_awesome,
        color: Colors.white,
        size: 64,
        shadows: [
          Shadow(
            blurRadius: 16,
            color: Colors.blueAccent.withOpacity(0.5),
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }
}
