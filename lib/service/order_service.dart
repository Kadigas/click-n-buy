import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fp_ppb/enums/courier.dart';
import 'package:fp_ppb/enums/status_order.dart';
import 'package:fp_ppb/enums/status_shipping.dart';
import 'package:fp_ppb/models/orders.dart';
import 'package:fp_ppb/service/auth_service.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addOrder(String storeID, double totalPrice, String address, CourierCategory courier, double shippingCost) {
    final Timestamp timestamp = Timestamp.now();
    final User user = AuthService().getCurrentUser()!;

    Orders newOrder = Orders(
      storeID: storeID,
      totalPrice: totalPrice,
      address: address,
      courier: courier,
      shippingCost: shippingCost,
      statusOrder: StatusOrder.waitingPayment,
      statusShipping: StatusShipping.unpaid,
      createdAt: timestamp,
      updatedAt: timestamp,
    );

    return _firestore.collection('users').doc(user.uid)
        .collection('orders')
        .add(newOrder.toMap());
  }
}
