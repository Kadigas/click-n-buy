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

  Future<void> updateHasStore(String docID) {
    final Timestamp timestamp = Timestamp.now();
    return users.doc(docID).update({'hasStore': true, 'updatedAt': timestamp});
  }

  Future<String> getUserCity(String docID) async {
    try {
      DocumentSnapshot snapshot = await users.doc(docID).get();
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
}
