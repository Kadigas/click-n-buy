import 'package:cloud_firestore/cloud_firestore.dart';

class StoreProduct {
  final String productName;
  final double productPrice;
  final int productStock;
  final String? imageUrl;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  StoreProduct({
    required this.productName,
    required this.productPrice,
    required this.productStock,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'productPrice': productPrice,
      'productStock': productStock,
      'imageUrl': imageUrl ?? "",
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}