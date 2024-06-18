import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fp_ppb/enums/courier.dart';
import 'package:fp_ppb/service/api_key_service.dart';
import 'package:fp_ppb/service/auth_service.dart';
import 'package:fp_ppb/service/order_service.dart';
import 'package:fp_ppb/service/user_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fp_ppb/components/my_button.dart';
import 'package:fp_ppb/service/cart_service.dart';
import 'package:fp_ppb/service/product_service.dart';
import 'package:intl/intl.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final CartService cartService = CartService();
  final ProductService productService = ProductService();
  final UserService userService = UserService();
  final OrderService orderService = OrderService();
  final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
  final Map<String, CourierCategory?> selectedCouriers = {};
  final Map<String, double> storeTotals = {};
  final Map<String, List<dynamic>> shippingOptions = {};
  final Map<String, Map<String, dynamic>?> selectedShippingOption = {};
  final Map<String, double> previousShippingCosts = {};
  final Map<String, double> shippingCosts = {};
  List<Map<String, dynamic>> checkedItems = [];
  double totalAmount = 0.0;

  final user = AuthService().getCurrentUser();

  @override
  void initState() {
    super.initState();
    fetchCheckedItems();
  }

  void _loadingState() {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Future<void> fetchCheckedItems() async {
    final cartItems = await cartService.getGroupedCartStream().first;
    List<Map<String, dynamic>> items = [];
    for (var entry in cartItems.entries) {
      for (var document in entry.value) {
        final data = document.data() as Map<String, dynamic>;
        if (data['isChecked']) {
          items.add({
            'storeID': entry.key,
            'document': document,
            'data': data,
          });
        }
      }
    }
    setState(() {
      checkedItems = items;
    });
    calculateStoreTotals();
  }

  Future<void> calculateStoreTotals() async {
    Map<String, double> totals = {};
    for (var item in checkedItems) {
      String storeID = item['storeID'];
      String productID = item['data']['productID'];
      int quantity = (item['data']['quantity'] as num).toInt();
      double productPrice = await productService.getProductPrice(productID);
      double itemTotal = productPrice * quantity;

      if (totals.containsKey(storeID)) {
        totals[storeID] = totals[storeID]! + itemTotal;
      } else {
        totals[storeID] = itemTotal;
      }
    }
    setState(() {
      storeTotals.addAll(totals);
      totalAmount = totals.values.fold(0, (sum, value) => sum + value);
    });
  }

  Future<void> fetchShippingOptions(
      String storeID, CourierCategory courier) async {
    final storeData = await cartService.getStoreDetails(storeID);
    final destinationID = await userService.getUserCity(user!.uid);
    final courierCode = courier.name;

    int totalWeight = 0;
    for (var item in checkedItems.where((item) => item['storeID'] == storeID)) {
      final productDetails =
          await productService.getProductDetails(item['data']['productID']);
      totalWeight += (productDetails['productWeight'] as num).toInt() *
          (item['data']['quantity'] as num).toInt();
    }

    final response = await http.post(
      Uri.parse('https://api.rajaongkir.com/starter/cost'),
      headers: {
        'key': APIKeyService().getAPIKey(),
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'origin': storeData['city'],
        'destination': destinationID,
        'weight': totalWeight.toString(),
        'courier': courierCode,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        shippingOptions[storeID] = data['rajaongkir']['results'][0]['costs'];
        selectedShippingOption[storeID] = null;
      });
    } else {
      print('Failed with status code: ${response.statusCode}');
      throw Exception('Failed to load shipping options');
    }
  }

  void updateShippingCost(String storeID, double newCost) {
    double previousCost = previousShippingCosts[storeID] ?? 0.0;
    double currentStoreTotal = storeTotals[storeID] ?? 0.0;
    storeTotals[storeID] = currentStoreTotal - previousCost + newCost;
    previousShippingCosts[storeID] = newCost;

    setState(() {
      totalAmount = storeTotals.values.fold(0, (sum, value) => sum + value);
    });
  }

  Future<void> checkQuantitiesAndCheckout(String storeID, double storeTotals,
      CourierCategory courierCategory, double shippingCost) async {
    bool allItemsAvailable = true;
    List<Map<String, dynamic>> storeItems =
        checkedItems.where((item) => item['storeID'] == storeID).toList();
    Map<String, int> stocks = {};

    for (var item in storeItems) {
      String productID = item['data']['productID'];
      int quantity = (item['data']['quantity'] as num).toInt();
      int stock = await productService.getProductStock(productID);
      stocks[productID] = stock;

      if (quantity > stock) {
        allItemsAvailable = false;
        Navigator.of(context, rootNavigator: true).pop();
        showErrorMessage('There\'s an item that is out of stock.');
        Navigator.pop(context);
        break;
      }
    }

    if (allItemsAvailable) {
      try {
        String address = await userService.getUserAddress(user!.uid);
        DocumentReference orderDocRef = await orderService.addOrder(
            storeID, storeTotals, address, courierCategory, shippingCost);
        await orderService.addStoreOrder(user!.uid, storeID, orderDocRef.id);

        for (var item in storeItems) {
          String productID = item['data']['productID'];
          int quantity = (item['data']['quantity'] as num).toInt();
          int newStock = stocks[productID]! - quantity;

          await orderService.addOrderItem(
              orderDocRef.id, storeID, productID, quantity);
          await cartService.deleteCartProduct(productID);
          await productService.updateProductStock(
              productID, newStock.toString());
          await productService.updateStoreProductStock(
              storeID, productID, newStock.toString());
        }
      } catch (e) {
        showErrorMessage(e.toString());
      }
    }
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.red,
          title: Center(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void showSuccessMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.green,
          title: Center(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Map<String, dynamic>>> groupedItems = {};
    for (var item in checkedItems) {
      String storeID = item['storeID'];
      if (!groupedItems.containsKey(storeID)) {
        groupedItems[storeID] = [];
      }
      groupedItems[storeID]!.add(item);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: ListView(
        children: groupedItems.entries.map((entry) {
          String storeID = entry.key;
          List<Map<String, dynamic>> items = entry.value;
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
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
                      String storeName = storeSnapshot.data ?? 'Unknown Store';
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Store: $storeName',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Column(
                            children: items.map((item) {
                              Map<String, dynamic> data = item['data'];
                              return FutureBuilder<Map<String, dynamic>>(
                                future: productService
                                    .getProductDetails(data['productID']),
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
                                  Map<String, dynamic>? productData =
                                      productSnapshot.data;
                                  return ListTile(
                                    title: Text(productData?['productName'] ??
                                        'Unknown Product'),
                                    subtitle: Text(
                                        'Quantity: ${(data['quantity'] as num).toInt()}'),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                          DropdownButtonFormField<CourierCategory>(
                            value: selectedCouriers[storeID],
                            decoration: const InputDecoration(
                                labelText: 'Select Courier'),
                            items: CourierCategory.values
                                .map((CourierCategory courier) {
                              return DropdownMenuItem<CourierCategory>(
                                value: courier,
                                child: Text(courier.displayName),
                              );
                            }).toList(),
                            onChanged: (courier) {
                              if (courier != null) {
                                setState(() {
                                  selectedCouriers[storeID] = courier;
                                  selectedShippingOption[storeID] = null;
                                });
                                fetchShippingOptions(storeID, courier);
                              }
                            },
                          ),
                          if (shippingOptions[storeID] != null)
                            DropdownButtonFormField<Map<String, dynamic>>(
                              value: selectedShippingOption[storeID],
                              decoration: const InputDecoration(
                                  labelText: 'Select Shipping Option'),
                              items: shippingOptions[storeID]!
                                  .map<DropdownMenuItem<Map<String, dynamic>>>(
                                      (option) {
                                return DropdownMenuItem<Map<String, dynamic>>(
                                  value: option,
                                  child: Text(
                                      '${option['service']} - ${option['cost'][0]['value']}'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    selectedShippingOption[storeID] = value;
                                    double newShippingCost =
                                        value['cost'][0]['value']?.toDouble() ??
                                            0.0;
                                    updateShippingCost(
                                        storeID, newShippingCost);
                                    shippingCosts[storeID] = newShippingCost;
                                  });
                                }
                              },
                            ),
                          Text(
                            'Total: ${formatCurrency.format(storeTotals[storeID] ?? 0)}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          MyButton(
                            onTap: () async {
                              _loadingState();
                              await checkQuantitiesAndCheckout(
                                  storeID,
                                  storeTotals[storeID]!,
                                  selectedCouriers[storeID]!,
                                  shippingCosts[storeID]!);
                              Navigator.of(context, rootNavigator: true).pop();
                              Navigator.pop(context);
                              Navigator.pop(context);
                              showSuccessMessage("Success place an order!");
                            },
                            msg: 'Checkout $storeName',
                            color: Colors.black,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 50,
          child: MyButton(
            onTap: () async {
              _loadingState();
              for (var storeID in groupedItems.keys) {
                await checkQuantitiesAndCheckout(storeID, storeTotals[storeID]!,
                    selectedCouriers[storeID]!, shippingCosts[storeID]!);
              }
              Navigator.of(context, rootNavigator: true).pop();
              Navigator.pop(context);
              Navigator.pop(context);
              showSuccessMessage("Success place an order!");
            },
            msg: 'Proceed to Checkout All',
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
