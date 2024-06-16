import 'package:cloud_firestore/cloud_firestore.dart';

class Store {
  final String sellerUid;
  final String email;
  final String storeName;
  String? address;
  final String province;
  final String city;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  Store({
    required this.sellerUid,
    required this.email,
    required this.storeName,
    this.address,
    required this.province,
    required this.city,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'sellerUid': sellerUid,
      'email': email,
      'storeName': storeName,
      'address': address ?? "",
      'province': province,
      'city': city,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}