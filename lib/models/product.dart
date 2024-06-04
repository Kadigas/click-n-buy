import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String storeID;
  final String productName;
  final String productDescription;
  final String productCategory;
  final double productPrice;
  final int productStock;
  final String productCondition;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final String? imageUrl;

  Product({
    required this.storeID,
    required this.productName,
    required this.productDescription,
    required this.productCategory,
    required this.productPrice,
    required this.productStock,
    required this.productCondition,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
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
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'imageUrl' : imageUrl?? ""
    };
  }
}
