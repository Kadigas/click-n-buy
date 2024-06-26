import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fp_ppb/enums/status_order.dart';
import 'package:fp_ppb/enums/status_shipping.dart';
import 'package:fp_ppb/models/orders.dart';
import 'package:fp_ppb/models/order_item.dart';
import 'package:fp_ppb/models/store_orders.dart';
import 'package:fp_ppb/pages/seller/store_order_detail_page.dart';
import 'package:fp_ppb/service/order_service.dart';
import 'package:fp_ppb/service/product_service.dart';
import 'package:fp_ppb/components/image_product.dart';

class StoreTransactionPage extends StatefulWidget {
  final String storeID;

  const StoreTransactionPage({super.key, required this.storeID});

  @override
  _StoreTransactionPageState createState() => _StoreTransactionPageState();
}

class _StoreTransactionPageState extends State<StoreTransactionPage> {
  final OrderService orderService = OrderService();
  final ProductService productService = ProductService();
  final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  Future<List<StoreOrders>> fetchStoreOrders() async {
    List<StoreOrders> storeOrders =
        await orderService.fetchStoreOrders(widget.storeID);
    storeOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return storeOrders;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Store Transactions',
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.greenAccent],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<List<StoreOrders>>(
        future: fetchStoreOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          List<StoreOrders> storeOrders = snapshot.data!;
          return ListView.builder(
            itemCount: storeOrders.length,
            itemBuilder: (context, index) {
              StoreOrders storeOrder = storeOrders[index];

              return Column(
                children: [
                  const SizedBox(
                    height: 5,
                  ),
                  FutureBuilder<Orders>(
                    future: orderService.fetchOrder(
                        storeOrder.userID, storeOrder.orderID),
                    builder: (context, orderSnapshot) {
                      if (orderSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const ListTile(
                          title: Text('Loading...'),
                        );
                      }
                      if (orderSnapshot.hasError) {
                        return ListTile(
                          title: Text('Error: ${orderSnapshot.error}'),
                        );
                      }

                      Orders order = orderSnapshot.data!;

                      return FutureBuilder<List<OrderItem>>(
                        future: orderService.fetchOrderItems(
                            storeOrder.userID, storeOrder.orderID),
                        builder: (context, itemSnapshot) {
                          if (itemSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const ListTile(
                              title: Text('Loading...'),
                            );
                          }
                          if (itemSnapshot.hasError) {
                            return ListTile(
                              title: Text('Error: ${itemSnapshot.error}'),
                            );
                          }
                          if (!itemSnapshot.hasData ||
                              itemSnapshot.data!.isEmpty) {
                            return const ListTile(
                              title: Text('No items found.'),
                            );
                          }

                          OrderItem firstItem = itemSnapshot.data!.first;

                          return FutureBuilder<Map<String, dynamic>>(
                            future: productService
                                .getProductDetails(firstItem.productID),
                            builder: (context, productSnapshot) {
                              if (productSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const ListTile(
                                  title: Text('Loading product...'),
                                );
                              }
                              if (productSnapshot.hasError) {
                                return ListTile(
                                  title: Text(
                                      'Error: ${productSnapshot.error}'),
                                );
                              }
                              if (!productSnapshot.hasData) {
                                return const ListTile(
                                  title: Text('No product details found.'),
                                );
                              }

                              Map<String, dynamic> productData =
                                  productSnapshot.data!;
                              String? imageUrl = productData['imageUrl'];

                              return Card(
                                child: ListTile(
                                  leading: Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.white,
                                    child: Center(
                                      child: ImageProduct(
                                        imageUrl: imageUrl,
                                      ),
                                    ),
                                  ),
                                  title: Row(
                                    children: [
                                      Text("#INV${storeOrder.orderID}"),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Total Price: ${formatCurrency.format(order.totalPrice)}'),
                                      Text(
                                          'Payment Status: ${order.statusOrder.displayName}'),
                                      Text(
                                          'Shipping Status: ${order.statusShipping.displayName}'),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                          '${dateFormat.format(order.createdAt.toDate())}'),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            OrderDetailPage(
                                          userID: storeOrder.userID,
                                          orderID: storeOrder.orderID,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
