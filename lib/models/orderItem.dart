import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String storeID;
  final String productID;
  final double productPrice;
  final int quantity;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  OrderItem({
    required this.storeID,
    required this.productID,
    required this.productPrice,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'storeID': storeID,
      'productID': productID,
      'productPrice': productPrice,
      'quantity': quantity,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}