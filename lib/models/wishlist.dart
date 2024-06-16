import 'package:cloud_firestore/cloud_firestore.dart';

class WishlistItem {
  final String storeID;
  final String productID;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final String productName;
  final double productPrice;
  final String? imageUrl;

  WishlistItem({
    required this.storeID,
    required this.productID,
    required this.createdAt,
    required this.updatedAt,
    required this.productName,
    required this.productPrice,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'storeID': storeID,
      'productID': productID,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'productName': productName,
      'productPrice': productPrice,
      'imageUrl': imageUrl,
    };
  }

  factory WishlistItem.fromMap(Map<String, dynamic> map) {
    return WishlistItem(
      storeID: map['storeID'],
      productID: map['productID'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
      productName: map['productName'],
      productPrice: map['productPrice'],
      imageUrl: map['imageUrl'],
    );
  }
}
