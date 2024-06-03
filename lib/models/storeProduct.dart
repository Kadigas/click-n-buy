import 'package:cloud_firestore/cloud_firestore.dart';

class StoreProduct {
  final String productName;
  final double productPrice;
  final int productStock;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  StoreProduct({
    required this.productName,
    required this.productPrice,
    required this.productStock,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'productPrice': productPrice,
      'productStock': productStock,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}