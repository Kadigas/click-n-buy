import 'package:cloud_firestore/cloud_firestore.dart';

class Stores {
  final String uid;
  final String email;
  final String storeName;
  final String address;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  Stores({
    required this.uid,
    required this.email,
    required this.storeName,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'storeName': storeName,
      'address': address,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}