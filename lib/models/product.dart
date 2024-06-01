import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String sellerUid;
  final String productName;
  final String productDescription;
  final String productCategory;
  final String productPrice;
  final String productStock;
  final String productCondition;
  final Timestamp timestamp;

  Product({
    required this.sellerUid,
    required this.productName,
    required this.productDescription,
    required this.productCategory,
    required this.productPrice,
    required this.productStock,
    required this.productCondition,
    required this.timestamp
  });

  Map<String, dynamic> toMap() {
    return {
      'sellerUid': sellerUid,
      'productName': productName,
      'productDescription': productDescription,
      'productCategory': productCategory,
      'productPrice': productPrice,
      'productStock': productStock,
      'productCondition': productCondition,
      'timestamp': timestamp
    };
  }
}