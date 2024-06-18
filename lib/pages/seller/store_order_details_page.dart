import 'package:flutter/material.dart';
import 'package:fp_ppb/components/image_product.dart';
import 'package:fp_ppb/service/location_cloud_service.dart';
import 'package:fp_ppb/service/user_service.dart';
import 'package:fp_ppb/enums/status_order.dart';
import 'package:fp_ppb/enums/status_shipping.dart';
import 'package:fp_ppb/models/order_item.dart';
import 'package:fp_ppb/models/orders.dart';
import 'package:fp_ppb/service/order_service.dart';
import 'package:fp_ppb/service/product_service.dart';
import 'package:intl/intl.dart';

class OrderDetailPage extends StatefulWidget {
  final String userID;
  final String orderID;

  OrderDetailPage({required this.userID, required this.orderID});

  @override
  _OrderDetailPageState createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  final OrderService orderService = OrderService();
  final ProductService productService = ProductService();
  final UserService userService = UserService();
  final locationCloudService = LocationCloudService();
  final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
  late Future<List<OrderItem>> _orderItemsFuture;
  late Future<Orders> _orderFuture;
  late Future<Map<String, dynamic>> _userFuture;
  late StatusOrder _currentStatusOrder;
  late StatusShipping _currentStatusShipping;
  String? _receiptNumber;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  _fetchData() {
    _orderItemsFuture =
        orderService.fetchOrderItems(widget.userID, widget.orderID);
    _orderFuture = orderService.fetchOrder(widget.userID, widget.orderID);
    _userFuture = userService.fetchUserDetails(widget.userID);
  }

  void showShippingReceiptDialog(
      BuildContext context, Function(String) onSubmit) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Shipping Receipt Number'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Receipt Number'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onSubmit(controller.text);
                Navigator.of(context).pop();
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userFuture,
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (userSnapshot.hasError) {
            return Center(child: Text('Error: ${userSnapshot.error}'));
          }
          if (!userSnapshot.hasData) {
            return const Center(child: Text('User not found.'));
          }

          Map<String, dynamic> user = userSnapshot.data!;
          String userName = user['username'];
          String firstName = user['firstName'];
          String lastName = user['lastName'];

          return FutureBuilder<Orders>(
            future: _orderFuture,
            builder: (context, orderSnapshot) {
              if (orderSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (orderSnapshot.hasError) {
                return Center(child: Text('Error: ${orderSnapshot.error}'));
              }
              if (!orderSnapshot.hasData) {
                return const Center(child: Text('Order not found.'));
              }

              Orders order = orderSnapshot.data!;
              _currentStatusOrder = order.statusOrder;
              _currentStatusShipping = order.statusShipping;
              _receiptNumber = order.receiptNumber;
              String userAddress = order.address;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.blue,
                    padding: const EdgeInsets.all(16),
                    child: const Text(
                      'Customer Information',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name: $firstName $lastName',
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 10),
                        Text('Username: $userName',
                            style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 5),
                        Text('Address: $userAddress',
                            style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 10),
                        if (_receiptNumber != null)
                          Text('Receipt Number: $_receiptNumber',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: double.infinity,
                    color: Colors.blue,
                    padding: const EdgeInsets.all(16),
                    child: const Text(
                      'Purchased Items',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: FutureBuilder<List<OrderItem>>(
                      future: _orderItemsFuture,
                      builder: (context, itemSnapshot) {
                        if (itemSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (itemSnapshot.hasError) {
                          return Center(
                              child: Text('Error: ${itemSnapshot.error}'));
                        }
                        if (!itemSnapshot.hasData ||
                            itemSnapshot.data!.isEmpty) {
                          return const Center(child: Text('No items found.'));
                        }

                        List<OrderItem> orderItems = itemSnapshot.data!;
                        return ListView.builder(
                          itemCount: orderItems.length,
                          itemBuilder: (context, index) {
                            OrderItem item = orderItems[index];
                            return FutureBuilder<Map<String, dynamic>>(
                              future: productService
                                  .getProductDetails(item.productID),
                              builder: (context, productSnapshot) {
                                if (productSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const ListTile(
                                    title: Text('Loading product...'),
                                  );
                                }
                                if (productSnapshot.hasError) {
                                  return ListTile(
                                    title:
                                        Text('Error: ${productSnapshot.error}'),
                                  );
                                }
                                if (!productSnapshot.hasData) {
                                  return const ListTile(
                                    title: Text('No product details found.'),
                                  );
                                }

                                Map<String, dynamic> productData =
                                    productSnapshot.data!;
                                String imageUrl = productData['imageUrl'] ?? '';
                                String productName =
                                    productData['productName'] ?? '';
                                String productPrice = formatCurrency
                                    .format(productData['productPrice'] ?? 0.0);

                                return ListTile(
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
                                  title: Text(productName),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Price: $productPrice'),
                                      Text('Quantity: ${item.quantity}'),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DropdownButton<StatusOrder>(
                        value: _currentStatusOrder,
                        items: StatusOrder.values.map((StatusOrder status) {
                          return DropdownMenuItem<StatusOrder>(
                            value: status,
                            child: Text(status.displayName),
                          );
                        }).toList(),
                        onChanged: (newValue) async {
                          if (newValue != null) {
                            await orderService.updateOrderStatus(
                              widget.userID,
                              widget.orderID,
                              newValue,
                              _currentStatusShipping,
                            );
                            setState(() {
                              _currentStatusOrder = newValue;
                            });
                          }
                        },
                      ),
                      DropdownButton<StatusShipping>(
                        value: _currentStatusShipping,
                        items:
                            StatusShipping.values.map((StatusShipping status) {
                          return DropdownMenuItem<StatusShipping>(
                            value: status,
                            child: Text(status.displayName),
                          );
                        }).toList(),
                        onChanged: (newValue) async {
                          if (newValue != null) {
                            if (newValue == StatusShipping.onShipping) {
                              showShippingReceiptDialog(context,
                                  (receiptNumber) async {
                                await orderService.updateOrderStatus(
                                  widget.userID,
                                  widget.orderID,
                                  _currentStatusOrder,
                                  newValue,
                                  receiptNumber: receiptNumber,
                                );
                                setState(() {
                                  _currentStatusShipping = newValue;
                                  _receiptNumber = receiptNumber;
                                  _fetchData();
                                });
                              });
                            } else {
                              await orderService.updateOrderStatus(
                                widget.userID,
                                widget.orderID,
                                _currentStatusOrder,
                                newValue,
                              );
                              setState(() {
                                _currentStatusShipping = newValue;
                                _fetchData();
                              });
                            }
                          }
                        },
                      ),
                    ],
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
