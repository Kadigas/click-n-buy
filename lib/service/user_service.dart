import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fp_ppb/models/users.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference users =
  FirebaseFirestore.instance.collection('users');

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<void> updateHasStore(String docID){
    final Timestamp timestamp = Timestamp.now();
    return users.doc(docID).update({
      'hasStore': true,
      'updatedAt': timestamp
    });
  }
}