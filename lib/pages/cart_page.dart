import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fp_ppb/components/image_product.dart';
import 'package:fp_ppb/service/cart_service.dart';
import 'package:fp_ppb/service/product_service.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartService cartService = CartService();
  final ProductService productService = ProductService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
      ),
      body: StreamBuilder<Map<String, List<DocumentSnapshot>>>(
        stream: cartService.getGroupedCartStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Your cart is empty'));
          }

          Map<String, List<DocumentSnapshot>> groupedCartItems = snapshot.data!;

          return ListView.builder(
            itemCount: groupedCartItems.keys.length,
            itemBuilder: (context, index) {
              String storeID = groupedCartItems.keys.elementAt(index);
              List<DocumentSnapshot> storeCartItems =
                  groupedCartItems[storeID]!;

              return Column(
                children: [
                  FutureBuilder<String>(
                    future: cartService.getStoreName(storeID),
                    builder: (context, storeSnapshot) {
                      if (storeSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (storeSnapshot.hasError) {
                        return Center(
                            child: Text('Error: ${storeSnapshot.error}'));
                      }

                      return Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent,
                        ),
                        child: ExpansionTile(
                          title: Row(
                            children: [
                              const Icon(Icons.storefront),
                              const SizedBox(width: 10),
                              Text('${storeSnapshot.data}'),
                            ],
                          ),
                          initiallyExpanded: true,
                          children: storeCartItems.map((document) {
                            Map<String, dynamic> data =
                                document.data() as Map<String, dynamic>;
                            String productID = data['productID'];
                            int quantity = data['quantity'];

                            return FutureBuilder<Map<String, dynamic>>(
                              future: productService.getStoreProduct(
                                  storeID, productID),
                              builder: (context, productSnapshot) {
                                if (productSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (productSnapshot.hasError) {
                                  return Center(
                                      child: Text(
                                          'Error: ${productSnapshot.error}'));
                                }

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                  child: ListTile(
                                    leading: Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.white,
                                      child: Center(
                                        child: ImageProduct(
                                          imageUrl:
                                              productSnapshot.data?['imageUrl'],
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                        '${productSnapshot.data?['productName']}'),
                                    subtitle: Text('Quantity: $quantity'),
                                    trailing: Checkbox(
                                      value: true,
                                      onChanged: (value) {},
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
