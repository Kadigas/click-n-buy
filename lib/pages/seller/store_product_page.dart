import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fp_ppb/components/image_product.dart';
import 'package:fp_ppb/components/small_button.dart';
import 'package:fp_ppb/pages/seller/store_show_product.dart';
import 'package:intl/intl.dart';
import 'package:fp_ppb/components/my_textfield.dart';
import 'package:fp_ppb/pages/chat/list_chat_page.dart';
import 'package:fp_ppb/pages/seller/add_product.dart';
import 'package:fp_ppb/service/product_service.dart';

class StoreProductPage extends StatefulWidget {
  final String storeID;

  const StoreProductPage({super.key, required this.storeID});

  @override
  State<StoreProductPage> createState() => _StoreProductPageState();
}

class _StoreProductPageState extends State<StoreProductPage> {
  final user = FirebaseAuth.instance.currentUser!;

  final ProductService productService = ProductService();

  final itemController = TextEditingController();

  final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');

  void changePrice(String productID, String newPrice) {
    productService.updateProductPrice(productID, newPrice);
    productService.updateStoreProductPrice(widget.storeID, productID, newPrice);
  }

  void changeStock(String productID, String newStock) {
    productService.updateProductStock(productID, newStock);
    productService.updateStoreProductStock(widget.storeID, productID, newStock);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Products', style: TextStyle(color: Colors.white),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: productService.getStoreProductStream(widget.storeID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return SafeArea(
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: MyTextField(
                              controller: itemController,
                              hintText: "Search...",
                              obscureText: false,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddProductPage(
                                        storeID: widget.storeID,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.upload),
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ListUserPage(isSeller: true),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.chat),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: MediaQuery.of(context).size.height - 200,
                        child: const Center(
                          child: Text('No Product.'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          List productList = snapshot.data!.docs;

          return SafeArea(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: MyTextField(
                            controller: itemController,
                            hintText: "Search...",
                            obscureText: false,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddProductPage(
                                      storeID: widget.storeID,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.upload),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ListUserPage(
                                      isSeller: true,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.chat),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: productList.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot document = productList[index];
                        String productID = document.id;
                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;
                        String productName = data['productName'];
                        double productPrice = data['productPrice'];
                        int productStock = data['productStock'];
                        String? imageUrl = data['imageUrl'];
                        String price = formatCurrency.format(productPrice);

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StoreShowProductPage(
                                  productID: productID,
                                  storeID: widget.storeID,
                                ),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 100,
                                        color: Colors.white,
                                        child: ImageProduct(
                                          imageUrl: imageUrl,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              productName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18.0,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              price,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text('Stock: $productStock'),
                                            const SizedBox(height: 10),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                SmallButton(
                                                  msg: 'Change Price',
                                                  color: Colors.black,
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        final priceController =
                                                            TextEditingController();
                                                        priceController.text =
                                                            productPrice
                                                                .toInt()
                                                                .toString();
                                                        return AlertDialog(
                                                          title: const Text(
                                                              'Change Price'),
                                                          content: TextField(
                                                            controller:
                                                                priceController,
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            decoration:
                                                                const InputDecoration(
                                                              hintText:
                                                                  'New Price',
                                                            ),
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: const Text(
                                                                  'Cancel'),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                String
                                                                    newPrice =
                                                                    priceController
                                                                        .text;
                                                                changePrice(
                                                                    productID,
                                                                    newPrice);
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: const Text(
                                                                  'Change'),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                                const SizedBox(width: 5),
                                                SmallButton(
                                                  msg: 'Change Stock',
                                                  color: Colors.black,
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        final stockController =
                                                            TextEditingController();
                                                        stockController.text =
                                                            productStock
                                                                .toString();
                                                        return AlertDialog(
                                                          title: const Text(
                                                              'Change Stock'),
                                                          content: TextField(
                                                            controller:
                                                                stockController,
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            decoration:
                                                                const InputDecoration(
                                                              hintText:
                                                                  'New Stock',
                                                            ),
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: const Text(
                                                                  'Cancel'),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                String
                                                                    newStock =
                                                                    stockController
                                                                        .text;
                                                                changeStock(
                                                                    productID,
                                                                    newStock);
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: const Text(
                                                                  'Change'),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
