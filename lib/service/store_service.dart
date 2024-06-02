import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fp_ppb/models/product.dart';
import 'package:fp_ppb/models/store.dart';

class StoreService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference stores =
  FirebaseFirestore.instance.collection('stores');

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<void> registerStore(String email, storeName,
      address) {
    final Timestamp timestamp = Timestamp.now();

    final User user = getCurrentUser()!;

    Store newStore = Store(
        sellerUid: user.uid,
        email: email,
        storeName: storeName,
        address: address,
        createdAt: timestamp,
        updatedAt: timestamp);

    return stores.add(newStore.toMap());
  }
}