import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<UserCredential> signInWithEmailPassword(String email, password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      // save user info if it doesn't exist
      _firestore.collection("users").doc(userCredential.user!.uid).set(
        {
          "uid": userCredential.user!.uid,
          'email': email
        }
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<UserCredential> signUpWithEmailPassword(String email, password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Update the user's display name
      // await userCredential.user?.updateProfile(displayName: displayName);

      // Optionally, you might want to reload the user to get the updated information
      // await userCredential.user?.reload();

      // Get the updated user
      // User? updatedUser = FirebaseAuth.instance.currentUser;

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future signOut() async {
    return await _auth.signOut();
  }
}
