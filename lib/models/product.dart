import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String storeID;
  final String productName;
  final String productDescription;
  final String productCategory;
  final double productPrice;
  final int productStock;
  final String productCondition;
  final double productWeight;
  final int productMinimumQuantity;
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
    required this.productMinimumQuantity,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  // Method to convert a Product instance to a Map
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
      'productMinimumQuantity': productMinimumQuantity,
      'imageUrl': imageUrl ?? "",
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Factory constructor to create a Product instance from a Map
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      storeID: map['storeID'],
      productName: map['productName'],
      productDescription: map['productDescription'],
      productCategory: map['productCategory'],
      productPrice: map['productPrice'],
      productStock: map['productStock'],
      productCondition: map['productCondition'],
      productWeight: map['productWeight'].toDouble(),
      productMinimumQuantity: map['productMinimumQuantity'],
      imageUrl: map['imageUrl'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }
}