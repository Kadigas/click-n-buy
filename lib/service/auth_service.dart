import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fp_ppb/models/users.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-credential':
          throw Exception('Incorrect email or password!');
        case 'invalid-email':
          throw Exception('Invalid email address.');
        case 'user-disabled':
          throw Exception('This user has been disabled.');
        case 'user-not-found':
          throw Exception('No user found with this email.');
        case 'wrong-password':
          throw Exception('Incorrect password.');
        default:
          throw Exception('An unknown error occurred.');
      }
    }
  }

  Future<UserCredential> signUpWithEmailPassword(String email, password, username, firstName, lastName) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Update the user's display name
      // await userCredential.user?.updateProfile(displayName: displayName);

      // Optionally, you might want to reload the user to get the updated information
      // await userCredential.user?.reload();

      // Get the updated user
      // User? updatedUser = FirebaseAuth.instance.currentUser;

      final Timestamp timestamp = Timestamp.now();

      Users newUser = Users(
          uid: userCredential.user!.uid,
          email: email,
          username: username,
          firstName: firstName,
          lastName: lastName,
          hasStore: false,
          address: '',
          createdAt: timestamp,
          updatedAt: timestamp,
      );

      _firestore.collection("users")
          .doc(userCredential.user!.uid)
          .set(newUser.toMap());

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future signOut() async {
    return await _auth.signOut();
  }
}
