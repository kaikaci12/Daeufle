import 'package:Daeufle/screens/course.dart';
import 'package:Daeufle/screens/welcome.dart';
import 'package:Daeufle/services/auth_manager.dart';
import 'package:flutter/material.dart';
import 'package:Daeufle/screens/quiz.dart'; // Import the QuizScreen
import 'dart:io' show Platform;

class Courses extends StatelessWidget {
  final List<Map<String, dynamic>> coursesData;
  final String
  careerRecommendation; // Renamed from careerRecomendation for consistency

  const Courses({
    super.key,
    required this.coursesData,
    required this.careerRecommendation,
  });

  @override
  Widget build(BuildContext context) {
    final AuthManager _authManager = AuthManager();

    // Prevent navigating back from this screen
    return WillPopScope(
      onWillPop: () async =>
          false, // This prevents the back button from working
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Recommended Courses"),
          centerTitle: true,
          automaticallyImplyLeading:
              false, // Hide the back button in the AppBar

          actions: [
            Row(
              children: [
                Text("Sign Out"),
                SizedBox(width: 20),
                IconButton(
                  icon: Icon(Icons.logout),

                  onPressed: () async {
                    String? error = await _authManager.signOut();
                    if (error == null) {
                      // If sign out is successful, navigate to WelcomePage
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => WelcomePage()),
                        (Route<dynamic> route) =>
                            false, // Clear navigation stack
                      );
                    } else {
                      // Show an error message if sign out failed
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Sign out failed: $error')),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                careerRecommendation,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 20),

              // Button to take the test again
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to QuizScreen and clear all previous routes
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const QuizScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Take Career Test Again",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "Recommended Courses:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              // List of Courses
              Expanded(
                child: ListView.builder(
                  itemCount: coursesData.length,
                  itemBuilder: (context, index) {
                    final course = coursesData[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return Course(courseData: course);
                            },
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: course['imageUrl'] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    course['imageUrl'],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.broken_image,
                                              size: 50,
                                            ),
                                  ),
                                )
                              : const Icon(Icons.school, size: 50),
                          title: Text(
                            course['title'] ?? 'No Title',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [Text(course['provider'] ?? '')],
                          ),
                          trailing: course['averageRating'] != null
                              ? Text('⭐ ${course['averageRating']}')
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
