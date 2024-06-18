import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fp_ppb/models/order_item.dart';
import 'package:fp_ppb/models/product.dart';
import 'package:fp_ppb/service/auth_service.dart';
import 'package:fp_ppb/service/order_service.dart';
import 'package:fp_ppb/service/product_service.dart';
import 'package:intl/intl.dart';
import 'package:badges/badges.dart' as custom_badges;

import '../../models/orders.dart';
import '../../service/store_service.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final AuthService _auth = AuthService();
  final OrderService _order = OrderService();
  final StoreService _store = StoreService();
  final ProductService _product = ProductService();
  final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
  late User user;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() {
    setState(() {
      user = _auth.getCurrentUser()!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Transactions",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: _order.getTransactions(user.uid),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Map<String, dynamic>> transactions = snapshot.data!;
              if (transactions.isEmpty) {
                return const Center(child: Text("Transaction is empty"));
              }
              return ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  Orders order = Orders.fromMap(transactions[index]);
                  String orderId = transactions[index]['id'];
                  return FutureBuilder(
                    future: _store.getStoreName(order.storeID),
                    builder: (context, storeNameSnapshot) {
                      if (storeNameSnapshot.connectionState == ConnectionState.waiting) {
                        return const ListTile(
                          title: Text('Loading...'),
                        );
                      } else if (storeNameSnapshot.hasError) {
                        return ListTile(
                          title: Text('Error: ${storeNameSnapshot.error}'),
                        );
                      } else if (!storeNameSnapshot.hasData) {
                        return const ListTile(
                          title: Text(
                            'No data available',
                            style: TextStyle(color: Colors.black),
                          ),
                        );
                      } else {
                        final String storeName = storeNameSnapshot.data!;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ExpansionTile(
                            title: Row(
                              children: [
                                Text(
                                  storeName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Spacer(),
                                custom_badges.Badge(
                                  badgeContent: Text(
                                    formatCurrency.format(order.totalPrice),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  badgeColor: Colors.blue,
                                  shape: custom_badges.BadgeShape.square,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.payment, size: 16),
                                    SizedBox(width: 5),
                                    Text("Status payment: ${order.statusOrder.name}"),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.local_shipping, size: 16),
                                    SizedBox(width: 5),
                                    Text("Status shipping: ${order.statusShipping.name}"),
                                  ],
                                ),
                                if (order.receiptNumber != null)
                                  Row(
                                    children: [
                                      Icon(Icons.receipt, size: 16),
                                      SizedBox(width: 5),
                                      Text("Receipt number: ${order.receiptNumber}"),
                                    ],
                                  ),
                              ],
                            ),
                            children: [
                              StreamBuilder(
                                stream: _order.getOrderItems(user.uid, orderId),
                                builder: (context, itemSnapshot) {
                                  if (itemSnapshot.connectionState == ConnectionState.waiting) {
                                    return const ListTile(
                                      title: Text('Loading items...'),
                                    );
                                  } else if (itemSnapshot.hasError) {
                                    return ListTile(
                                      title: Text('Error: ${itemSnapshot.error}'),
                                    );
                                  } else if (!itemSnapshot.hasData || itemSnapshot.data!.isEmpty) {
                                    return const ListTile(
                                      title: Text('No items in this order.'),
                                    );
                                  } else {
                                    List<Map<String, dynamic>> items = itemSnapshot.data!;
                                    return Column(
                                      children: items.map((item) {
                                        OrderItem orderItem = OrderItem.fromMap(item);
                                        return FutureBuilder(
                                          future: _product.getProductDetails(orderItem.productID),
                                          builder: (context, productSnapshot) {
                                            if (productSnapshot.connectionState == ConnectionState.waiting) {
                                              return const ListTile(
                                                title: Text('Loading product...'),
                                              );
                                            } else if (productSnapshot.hasError) {
                                              return ListTile(
                                                title: Text('Error: ${productSnapshot.error}'),
                                              );
                                            } else if (!productSnapshot.hasData || productSnapshot.data!.isEmpty) {
                                              return const ListTile(
                                                title: Text('No product in this order.'),
                                              );
                                            } else {
                                              Product product = Product.fromMap(productSnapshot.data!);
                                              return Card(
                                                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                                                elevation: 2,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: ListTile(
                                                  title: Text(product.productName),
                                                  subtitle: Text("Quantity: ${orderItem.quantity}"),
                                                  trailing: Text("Price: \₽${orderItem.productPrice}"),
                                                ),
                                              );
                                            }
                                          },
                                        );
                                      }).toList(),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  );
                },
              );
            } else if (snapshot.hasError) {
              return const Center(
                child: Text("Error while fetching transactions"),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}