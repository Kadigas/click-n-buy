import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String storeID;
  final String productID;
  final int quantity;
  final bool isChecked;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  OrderItem({
    required this.storeID,
    required this.productID,
    required this.quantity,
    required this.isChecked,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'storeID': storeID,
      'productID': productID,
      'quantity': quantity,
      'isChecked': isChecked,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}