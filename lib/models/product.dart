import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String storeID;
  final String productName;
  final String productDescription;
  final String productCategory;
  final double productPrice;
  final int productStock;
  final String productCondition;
  final String productWeight;
  final String? imageUrl;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  Product({
    required this.storeID,
    required this.productName,
    required this.productDescription,
    required this.productCategory,
    required this.productPrice,
    required this.productStock,
    required this.productCondition,
    required this.productWeight,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'storeID': storeID,
      'productName': productName,
      'productDescription': productDescription,
      'productCategory': productCategory,
      'productPrice': productPrice,
      'productStock': productStock,
      'productCondition': productCondition,
      'productWeight': productWeight,
      'imageUrl': imageUrl ?? "",
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
