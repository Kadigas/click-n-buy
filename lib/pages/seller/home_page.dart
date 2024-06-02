import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fp_ppb/components/my_button.dart';
import 'package:fp_ppb/pages/seller/show_product.dart';
import 'package:intl/intl.dart';
import 'package:fp_ppb/components/my_textfield.dart';
import 'package:fp_ppb/pages/list_user_page.dart';
import 'package:fp_ppb/pages/seller/add_product.dart';
import 'package:fp_ppb/pages/seller/edit_product.dart';
import 'package:fp_ppb/service/auth_service.dart';
import 'package:fp_ppb/service/product_service.dart';

class SellerHomePage extends StatefulWidget {
  const SellerHomePage({super.key});

  @override
  State<SellerHomePage> createState() => _SellerHomePageState();
}

class _SellerHomePageState extends State<SellerHomePage> {
  final user = FirebaseAuth.instance.currentUser!;

  final ProductService productService = ProductService();

  final itemController = TextEditingController();

  final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');

  void signUserOut() {
    final authService = AuthService();
    authService.signOut();
  }

  void changePrice(String productID, String newPrice) {
    productService.updateProductPrice(productID, newPrice);
  }

  void changeStock(String productID, String newStock) {
    productService.updateProductStock(productID, newStock);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: productService.getProductStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
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
                                      builder: (context) => const AddProductPage(),
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
                                      builder: (context) => ListUserPage(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.chat),
                              ),
                              IconButton(
                                onPressed: signUserOut,
                                icon: const Icon(Icons.logout),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'My Products',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 18.0),
                      ),
                      const SizedBox(height: 10),
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
                          String price = formatCurrency.format(productPrice);

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ShowProductPage(
                                    productID: productID,
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              child: Row(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.keyboard,
                                      size: 50,
                                    ),
                                  ),
                                  Expanded(
                                    child: ListTile(
                                      title: Text(
                                        productName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            price,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text('Stock: $productStock'),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              MyButton(
                                                msg: 'Change Price',
                                                color: Colors.black,
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      final priceController =
                                                          TextEditingController();
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
                                                                      'New Price'),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              String newPrice =
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
                                              MyButton(
                                                msg: 'Change Stock',
                                                color: Colors.black,
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      final stockController =
                                                          TextEditingController();
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
                                                                      'New Stock'),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              String newStock =
                                                                  stockController
                                                                      .text;
                                                              changePrice(
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
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        child: Text('Footer'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
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
                                onPressed: signUserOut,
                                icon: const Icon(Icons.logout),
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const AddProductPage(),
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
                                      builder: (context) => ListUserPage(),
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
                      const Center(
                        child: Text('No Product.'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
