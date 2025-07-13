import 'package:Daeufle/screens/quiz.dart';
import 'package:Daeufle/screens/welcome.dart';
import 'package:Daeufle/services/auth_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  // Use static final for Firebase instances that are globally accessed
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthManager _authManager = AuthManager();
  Stream<Map<String, dynamic>?> getUserDataStream() {
    User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      print('No user is currently signed in. Returning null stream.');
      return Stream.value(null);
    }

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
    final User? authUser = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return Home();
                },
              ),
            );
          },
          child: Image.asset("assets/images/tbc-logo.png"),
        ),

        title: LoadUserData(),
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
                      (Route<dynamic> route) => false, // Clear navigation stack
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
              "Before we move on to the courses, let's first take a career test",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => QuizScreen()));
              },
              child: Text("Start Test"),
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
