import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fp_ppb/components/image_product.dart';
import 'package:fp_ppb/components/my_button.dart';
import 'package:fp_ppb/components/quantity_editor.dart';
import 'package:fp_ppb/service/cart_service.dart';
import 'package:fp_ppb/service/product_service.dart';
import 'package:intl/intl.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartService cartService = CartService();
  final ProductService productService = ProductService();
  final Map<String, bool> checkedStates = {};
  final Map<String, int> quantities = {};
  final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
  final ValueNotifier<double> totalPrice = ValueNotifier<double>(0.0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initializeStates();
      await updateTotalPrice();
    });
  }

  Future<void> initializeStates() async {
    // Retrieve all cart items to initialize the checkedStates and quantities maps
    final cartItems = await cartService.getGroupedCartStream().first;
    for (var entry in cartItems.entries) {
      for (var document in entry.value) {
        final data = document.data() as Map<String, dynamic>;
        String documentId = document.id;
        if (!checkedStates.containsKey(documentId)) {
          checkedStates[documentId] = data['isChecked'];
        }
        if (!quantities.containsKey(documentId)) {
          quantities[documentId] = data['quantity'];
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<Map<String, List<DocumentSnapshot>>>(
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
                    List<DocumentSnapshot> storeCartItems = groupedCartItems[storeID]!;

                    return Column(
                      children: [
                        FutureBuilder<String>(
                          future: cartService.getStoreName(storeID),
                          builder: (context, storeSnapshot) {
                            if (storeSnapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (storeSnapshot.hasError) {
                              return Center(child: Text('Error: ${storeSnapshot.error}'));
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
                                  Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                                  String productID = data['productID'];
                                  int quantity = data['quantity'];
                                  bool isChecked = data['isChecked'];
                                  String documentId = document.id;

                                  // Initialize the local state if not already done
                                  if (!checkedStates.containsKey(documentId)) {
                                    checkedStates[documentId] = isChecked;
                                  }
                                  if (!quantities.containsKey(documentId)) {
                                    quantities[documentId] = quantity;
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                    child: FutureBuilder<Map<String, dynamic>>(
                                      future: productService.getStoreProduct(storeID, productID),
                                      builder: (context, productSnapshot) {
                                        if (productSnapshot.connectionState == ConnectionState.waiting) {
                                          return const Center(child: CircularProgressIndicator());
                                        }
                                        if (productSnapshot.hasError) {
                                          return Center(child: Text('Error: ${productSnapshot.error}'));
                                        }

                                        double productPrice = productSnapshot.data?['productPrice'] ?? 0.0;

                                        return Container(
                                          color: Colors.white38,
                                          child: ListTile(
                                            leading: Container(
                                              width: 80,
                                              height: 80,
                                              color: Colors.white,
                                              child: Center(
                                                child: ImageProduct(
                                                  imageUrl: productSnapshot.data?['imageUrl'],
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              '${productSnapshot.data?['productName']}',
                                              style: const TextStyle(fontSize: 14.0),
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  formatCurrency.format(productPrice),
                                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                                QuantityEditor(
                                                  initialQuantity: quantities[documentId]!,
                                                  onQuantityChanged: (newQuantity) async {
                                                    quantities[documentId] = newQuantity;
                                                    await updateTotalPrice();
                                                  },
                                                ),
                                              ],
                                            ),
                                            trailing: Checkbox(
                                              value: checkedStates[documentId],
                                              onChanged: (value) async {
                                                checkedStates[documentId] = value!;
                                                await cartService.updateCartCheckedState(documentId, value!);
                                                await updateTotalPrice();
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
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
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ValueListenableBuilder<double>(
                      valueListenable: totalPrice,
                      builder: (context, value, child) {
                        return Text(
                          formatCurrency.format(value),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ValueListenableBuilder<double>(
                  valueListenable: totalPrice,
                  builder: (context, value, child) {
                    if (value > 0) {
                      return MyButton(
                        onTap: () {
                        },
                        msg: 'Checkout',
                        color: Colors.black,
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> updateTotalPrice() async {
    double newTotal = 0.0;

    for (var entry in checkedStates.entries) {
      if (entry.value) {
        String documentId = entry.key;
        double price = await cartService.getPriceForProduct(documentId);
        int quantity = quantities[documentId]!;
        newTotal += price * quantity;
      }
    }

    totalPrice.value = newTotal;
  }
}
