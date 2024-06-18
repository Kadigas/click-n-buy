import 'package:cloud_firestore/cloud_firestore.dart';

class StoreOrders {
  final String userID;
  final String orderID;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  StoreOrders({
    required this.userID,
    required this.orderID,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userID': userID,
      'orderID': orderID,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
