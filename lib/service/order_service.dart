import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fp_ppb/enums/courier.dart';
import 'package:fp_ppb/enums/status_order.dart';
import 'package:fp_ppb/enums/status_shipping.dart';
import 'package:fp_ppb/models/order_item.dart';
import 'package:fp_ppb/models/orders.dart';
import 'package:fp_ppb/models/store_orders.dart';
import 'package:fp_ppb/service/auth_service.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Future<Orders> getOrderByUserId(String userId, )
  Stream<List<Map<String, dynamic>>> getTransactions(String userId) {
    return _firestore
        .collection("users")
        .doc(userId)
        .collection("orders")
        .orderBy("createdAt", descending: false)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id; // Add document ID to the data map
        return data;
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getOrderItems(
      String userId, String orderId) {
    return _firestore
        .collection("users")
        .doc(userId)
        .collection("orders")
        .doc(orderId)
        .collection("orderItems")
        .orderBy("createdAt", descending: false)
        .snapshots()
        .map((querySnapshot) =>
            querySnapshot.docs.map((doc) => doc.data()).toList());
  }

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

  Future<void> addOrderItem(String orderID, String storeID, String productID,
      int quantity) async {
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
      DocumentSnapshot storeSnapshot = await _firestore.collection('stores')
          .doc(storeID)
          .get();
      if (storeSnapshot.exists) {
        Map<String, dynamic> storeData = storeSnapshot.data() as Map<
            String,
            dynamic>;
        return storeData['storeName'] ?? 'Unknown Store';
      } else {
        return 'Unknown Store';
      }
    } catch (e) {
      return 'Unknown Store';
    }
  }

  Future<void> addStoreOrder(String userID, storeID, orderID) async {
    final Timestamp timestamp = Timestamp.now();

    StoreOrders newOrder = StoreOrders(
      userID: userID,
      orderID: orderID,
      createdAt: timestamp,
      updatedAt: timestamp,
    );

    await _firestore
        .collection('stores')
        .doc(storeID)
        .collection('orders')
        .doc(orderID)
        .set(newOrder.toMap());
  }

  Future<List<StoreOrders>> fetchStoreOrders(String storeID) async {
    List<StoreOrders> storeOrdersList = [];
    QuerySnapshot storeOrdersSnapshot = await _firestore
        .collection('stores')
        .doc(storeID)
        .collection('orders')
        .get();

    for (var doc in storeOrdersSnapshot.docs) {
      storeOrdersList.add(StoreOrders(
        userID: doc['userID'],
        orderID: doc['orderID'],
        createdAt: doc['createdAt'],
        updatedAt: doc['updatedAt'],
      ));
    }
    return storeOrdersList;
  }

  Future<Orders> fetchOrder(String userID, String orderID) async {
    DocumentSnapshot orderDoc = await _firestore
        .collection('users')
        .doc(userID)
        .collection('orders')
        .doc(orderID)
        .get();

    List<OrderItem> orderItems = await fetchOrderItems(userID, orderID);

    return Orders.fromMap(orderDoc.data() as Map<String, dynamic>, orderItems);
  }

  Future<List<OrderItem>> fetchOrderItems(String userID, String orderID) async {
    QuerySnapshot orderItemsSnapshot = await _firestore
        .collection('users')
        .doc(userID)
        .collection('orders')
        .doc(orderID)
        .collection('orderItems')
        .get();

    return orderItemsSnapshot.docs
        .map((doc) => OrderItem.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateOrderStatus(String userID, String orderID, StatusOrder statusOrder, StatusShipping statusShipping, {String? receiptNumber}) async {
    final Map<String, dynamic> updateData = {
      'statusOrder': statusOrder.name,
      'statusShipping': statusShipping.name,
    };
    if (receiptNumber != null) {
      updateData['receiptNumber'] = receiptNumber;
    }

    await _firestore
        .collection('users')
        .doc(userID)
        .collection('orders')
        .doc(orderID)
        .update(updateData);
  }
}
