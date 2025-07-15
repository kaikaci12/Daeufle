import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

      await user!.sendEmailVerification();

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'An account already exists for that email.';
      } else {
        return e.message ?? 'An unknown error occurred during sign up.';
      }
    } catch (e) {
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

      await userCredential.user!.reload();
      User? user = _auth.currentUser;

      print(user!.emailVerified);

      if (!user.emailVerified) {
        return "Please verify your email address to log in. A verification email has been sent.";
      }

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      } else if (e.code == 'invalid-email') {
        return 'The email address is not valid.';
      } else if (e.code == 'user-disabled') {
        return 'This user account has been disabled.';
      } else {
        return e.message ?? 'An unknown error occurred during sign in.';
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> signOut() async {
    try {
      await _auth.signOut();

      return null; // Sign out successful
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'An unknown error occurred during sign out.';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> sendPasswordResetLink(email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);

      return null;
    } on FirebaseException catch (e) {
      return e.message ??
          "Uknown error occured during sending password reset link";
    } catch (e) {
      return e.toString();
    }
  }
}
