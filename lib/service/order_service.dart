import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fp_ppb/enums/courier.dart';
import 'package:fp_ppb/enums/status_order.dart';
import 'package:fp_ppb/enums/status_shipping.dart';
import 'package:fp_ppb/models/orderItem.dart';
import 'package:fp_ppb/models/orders.dart';
import 'package:fp_ppb/service/auth_service.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentReference> addOrder(String storeID, double totalPrice,
      String address, CourierCategory courier, double shippingCost) {
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

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('orders')
        .add(newOrder.toMap());
  }

  Future<void> addOrderItem(
      String orderID, String storeID, String productID, int quantity) async {
    final Timestamp timestamp = Timestamp.now();

    final User user = AuthService().getCurrentUser()!;

    try {
      DocumentSnapshot productSnapshot =
      await _firestore.collection('products').doc(productID).get();

      if (!productSnapshot.exists) {
        throw Exception('Product not found');
      }

      Map<String, dynamic> productData =
      productSnapshot.data() as Map<String, dynamic>;
      double price = productData['productPrice'];

      OrderItem orderItem = OrderItem(
        storeID: storeID,
        productID: productID,
        quantity: quantity,
        productPrice: price,
        createdAt: timestamp,
        updatedAt: timestamp,
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('orders')
          .doc(orderID)
          .collection('orderItems')
          .doc(productID)
          .set(orderItem.toMap());
    } catch (e) {
      throw Exception('Failed to add to cart: $e');
    }
  }

  Future<List<DocumentSnapshot>> getUserOrders() async {
    final User user = AuthService().getCurrentUser()!;
    QuerySnapshot querySnapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('orders')
        .get();

    print('Fetched ${querySnapshot.docs.length} orders for user ${user.uid}');
    return querySnapshot.docs;
  }


  Future<String> getStoreName(String storeID) async {
    try {
      DocumentSnapshot storeSnapshot = await _firestore.collection('stores').doc(storeID).get();
      if (storeSnapshot.exists) {
        Map<String, dynamic> storeData = storeSnapshot.data() as Map<String, dynamic>;
        return storeData['storeName'] ?? 'Unknown Store';
      } else {
        return 'Unknown Store';
      }
    } catch (e) {
      return 'Unknown Store';
    }
  }
}
