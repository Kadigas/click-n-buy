import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<void> updateProfile(
    String uid,
    String username,
    String firstName,
    String lastName,
    String address,
    String city,
    String province,
    String? imageUrl,
  ) {
    final Timestamp timestamp = Timestamp.now();

    return users.doc(uid).update({
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'address': address,
      'city': city,
      'province': province,
      'imageUrl': imageUrl,
      'updatedAt': timestamp
    });
  }

  Future<Map<String, dynamic>> fetchUserDetails(String userID) async {
    DocumentSnapshot userDoc = await _firestore
        .collection('users')
        .doc(userID)
        .get();

    return userDoc.data() as Map<String, dynamic>;
  }

  Future<void> updateHasStore(String userID) {
    final Timestamp timestamp = Timestamp.now();
    return users.doc(userID).update({'hasStore': true, 'updatedAt': timestamp});
  }

  Future<String> getUserCity(String userID) async {
    try {
      DocumentSnapshot snapshot = await users.doc(userID).get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        return data['city'];
      } else {
        throw Exception('User city not found');
      }
    } catch (e) {
      throw Exception('Failed to get city: $e');
    }
  }

  Future<String> getUserAddress(String userID) async {
    try {
      DocumentSnapshot snapshot = await users.doc(userID).get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        return data['address'];
      } else {
        throw Exception('User address not found');
      }
    } catch (e) {
      throw Exception('Failed to get address: $e');
    }
  }
}
