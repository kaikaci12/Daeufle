import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthManager {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> signUpWithEmailAndPassword(
    String email,
    String password,
    String username,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      if (user != null) {
        final userRef = _firestore.collection('users').doc(user.uid);
        await userRef.set({
          "username": username,
          "email": email,
          "createdAt": FieldValue.serverTimestamp(),
        });
      }
      // After successful signup, send email verification
      await user!.sendEmailVerification();

      return null; // No error
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'An account already exists for that email.';
      } else {
        // Return a generic error message for other FirebaseAuthException codes
        return e.message ?? 'An unknown error occurred during sign up.';
      }
    } catch (e) {
      // Catch any other unexpected errors
      return e.toString();
    }
  }

  Future<String?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Reload the user to ensure the latest email verification status is fetched
      await userCredential.user!.reload();
      User? user = _auth.currentUser; // Get the reloaded user

      print(user!.emailVerified); // For debugging

      if (!user.emailVerified) {
        return "Please verify your email address to log in. A verification email has been sent.";
      }

      return null; // Sign in successful and email is verified, no error
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.'; // Explicitly return for user-not-found
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      } else if (e.code == 'invalid-email') {
        return 'The email address is not valid.';
      } else if (e.code == 'user-disabled') {
        return 'This user account has been disabled.';
      } else {
        // Return a generic error message for other FirebaseAuthException codes
        return e.message ?? 'An unknown error occurred during sign in.';
      }
    } catch (e) {
      // Catch any other unexpected errors
      return e.toString();
    }
  }
}
