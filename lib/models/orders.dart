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
  StatusOrder statusOrder;
  StatusShipping statusShipping;
  String? receiptNumber;
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
    this.receiptNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Orders.fromMap(Map<String, dynamic> map) {
    return Orders(
      storeID: map['storeID'],
      totalPrice: map['totalPrice'],
      address: map['address'],
      courier: CourierCategory.values.firstWhere((e) => e.name == map['courier']),
      shippingCost: map['shippingCost'],
      statusOrder: StatusOrder.values.firstWhere((e) => e.name == map['statusOrder']),
      statusShipping: StatusShipping.values.firstWhere((e) => e.name == map['statusShipping']),
      receiptNumber: map['receiptNumber'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'storeID': storeID,
      'totalPrice': totalPrice,
      'address': address,
      'courier': courier.name,
      'shippingCost': shippingCost,
      'statusOrder': statusOrder.name,
      'statusShipping': statusShipping.name,
      'receiptNumber': receiptNumber?? "",
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
