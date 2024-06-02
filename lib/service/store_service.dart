import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fp_ppb/models/product.dart';

class StoreService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference products =
  FirebaseFirestore.instance.collection('products');

  User? getCurrentUser() {
    return _auth.currentUser;
  }
}