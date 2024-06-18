import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fp_ppb/enums/courier.dart';
import 'package:fp_ppb/enums/status_order.dart';
import 'package:fp_ppb/enums/status_shipping.dart';

class Orders {
  final String storeID;
  final double totalPrice;
  final String address;
  final CourierCategory courier;
  final double shippingCost;
  final StatusOrder statusOrder;
  final StatusShipping statusShipping;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  Orders({
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
      'courier': courier.name,
      'shippingCost': shippingCost,
      'statusOrder': statusOrder.name,
      'statusShipping': statusShipping.name,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Factory constructor to create an Order instance from a Map
  factory Orders.fromMap(Map<String, dynamic> map) {
    return Orders(
      storeID: map['storeID'],
      totalPrice: map['totalPrice'],
      address: map['address'],
      courier: CourierCategory.values.firstWhere((e) => e.name == map['courier']),
      shippingCost: map['shippingCost'],
      statusOrder: StatusOrder.values.firstWhere((e) => e.name == map['statusOrder']),
      statusShipping: StatusShipping.values.firstWhere((e) => e.name == map['statusShipping']),
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }
}
