import 'package:Daeufle/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import "screens/welcome.dart";
import "screens/home.dart";
import "screens/courses.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize SharedPreferences once here, as it's used across the app
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(App(prefs: prefs)); // Pass SharedPreferences instance to the App
}

class App extends StatelessWidget {
  final SharedPreferences prefs;

  const App({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: false,
        primaryColor: const Color(0xFFE6B429),
        primarySwatch: MaterialColor(0xFFE6B429, <int, Color>{
          50: const Color(0xFFFDF7E3),
          100: const Color(0xFFF9EBB9),
          200: const Color(0xFFF4DE8B),
          300: const Color(0xFFEFD15D),
          400: const Color(0xFFECC739),
          500: const Color(0xFFE6B429),
          600: const Color(0xFFD4A524),
          700: const Color(0xFFC0941F),
          800: const Color(0xFFAC841A),
          900: const Color(0xFF916B10),
        }),
      ),
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(), // Use AuthWrapper as the home screen
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),

      builder: (context, snapshot) {
        print("auth state chaned");
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          final currentUser = snapshot.data!;
          print("User logged in: ${currentUser.uid}");

          // 🔍 Now check for quiz results
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection("users")
                .doc(currentUser.uid)
                .collection("quizResults")
                .doc("latest")
                .get(),
            builder: (context, quizSnapshot) {
              if (quizSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (quizSnapshot.hasError) {
                print("Error fetching quiz results: ${quizSnapshot.error}");
                return Home(); // Fall back to Home if error
              }

              if (quizSnapshot.hasData &&
                  quizSnapshot.data!.exists &&
                  quizSnapshot.data!.data() != null) {
                final data = quizSnapshot.data!.data() as Map<String, dynamic>;
                final List<dynamic>? rawCoursesData =
                    data['suitableCourses'] as List<dynamic>?;
                final String? recommendation =
                    data['careerRecommendation'] as String?;

                if (rawCoursesData != null && recommendation != null) {
                  final coursesData = rawCoursesData
                      .whereType<Map<String, dynamic>>()
                      .toList();
                  print("Quiz results found, going to Courses!");
                  return Courses(
                    coursesData: coursesData,
                    careerRecommendation: recommendation,
                  );
                }
              }

              // If no quiz results -> Home to take quiz
              print("No quiz results found. Go to Home to take quiz.");
              return Home();
            },
          );
        } else {
          return WelcomePage();
        }
      },
    );
  }
}
