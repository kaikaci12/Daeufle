import 'dart:convert';

import 'package:Daeufle/screens/quiz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Home extends StatelessWidget {
  // Use static final for Firebase instances that are globally accessed
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // This function now returns a Stream of user data (Map<String, dynamic>?)
  // The '?' indicates that the map itself can be null if the document doesn't exist.
  Stream<Map<String, dynamic>?> getUserDataStream() {
    User? currentUser = _auth.currentUser; // Get the current Firebase Auth user

    // If no user is signed in, return a stream that immediately emits null.
    // This prevents trying to fetch from Firestore with a null UID.
    if (currentUser == null) {
      print('No user is currently signed in. Returning null stream.');
      return Stream.value(null);
    }

    // Get a reference to the specific user's document in the 'users' collection
    final userDocRef = _firestore.collection("users").doc(currentUser.uid);

    return userDocRef.snapshots().map((snapshot) {
      if (snapshot.exists) {
        return snapshot.data(); // Returns Map<String, dynamic>
      } else {
        print(
          'User document for UID ${currentUser.uid} does not exist in Firestore.',
        );
        return null; // Document does not exist
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the current Firebase Auth user details (available immediately after login)
    final User? authUser = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.home),
        title: LoadUserData(),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Handle settings button press
            },
          ),

          // Example: Sign out button add later
        ],
      ),
      endDrawer: const Drawer(
        child: Column(
          children: [
            DrawerHeader(child: Text("App Drawer")),
            // Add other drawer items here
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(20),
        child: Column(
          children: [
            Text(
              "სანამ კურსებზე გადავიდოდეთ მოდი ჯერ გავიაროთ კარიერული ტესტი",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => QuizScreen()),
                );
              },
              child: Text("ტესტის დაწეყება"),
            ),
          ],
        ),
      ),
    );
  }

  StreamBuilder<Map<String, dynamic>?> LoadUserData() {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: getUserDataStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text(
            'Error loading user data: ${snapshot.error}',
            style: const TextStyle(color: Colors.red),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          final Map<String, dynamic> userData = snapshot.data!;
          return Text(
            '${userData['username'] ?? 'N/A'}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          );
        } else {
          return const Text(
            'No detailed user profile found in Firestore for this account.',
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
          );
        }
      },
    );
  }
}
