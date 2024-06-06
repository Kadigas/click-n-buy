import 'package:cloud_firestore/cloud_firestore.dart';

class Cart {
  final String storeID;
  final String productID;
  final int quantity;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  Cart({
    required this.storeID,
    required this.productID,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'storeID': storeID,
      'productID': productID,
      'quantity': quantity,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}