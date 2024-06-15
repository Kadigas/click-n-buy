import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String storeID;
  final String totalPrice;
  final String address;
  final String courier;
  final String shippingCost;
  final String statusOrder;
  final String statusShipping;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  Order({
    required this.storeID,
    required this.totalPrice,
    required this.address,
    required this.courier,
    required this.shippingCost,
    required this.statusOrder,
    required this.statusShipping,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'storeID': storeID,
      'totalPrice': totalPrice,
      'address': address,
      'courier': courier,
      'shippingCost': shippingCost,
      'statusOrder': statusOrder,
      'statusShipping': statusShipping,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}