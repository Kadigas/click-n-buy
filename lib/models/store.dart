import 'package:cloud_firestore/cloud_firestore.dart';

class Store {
  final String sellerUid;
  final String email;
  final String storeName;
  final String address;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  Store({
    required this.sellerUid,
    required this.email,
    required this.storeName,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'sellerUid': sellerUid,
      'email': email,
      'storeName': storeName,
      'address': address,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}