import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fp_ppb/components/my_textfield.dart';
import 'package:fp_ppb/pages/list_user_page.dart';
import 'package:fp_ppb/pages/seller/add_product.dart';
import 'package:fp_ppb/pages/seller/edit_product.dart';
import 'package:fp_ppb/service/auth_service.dart';
import 'package:fp_ppb/service/product_service.dart';

class GridSellerHomePage extends StatefulWidget {
  const GridSellerHomePage({super.key});

  @override
  State<GridSellerHomePage> createState() => _GridSellerHomePageState();
}

class _GridSellerHomePageState extends State<GridSellerHomePage> {
  final user = FirebaseAuth.instance.currentUser!;

  final ProductService productService = ProductService();

  final itemController = TextEditingController();

  final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');

  void signUserOut() {
    final authService = AuthService();
    authService.signOut();
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
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: MyTextField(
                                controller: itemController,
                                hintText: "Search...",
                                obscureText: false),
                          ),
                          Row(
                            children: [
                              IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AddProductPage()));
                                  },
                                  icon: const Icon(Icons.upload)),
                              IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ListUserPage()));
                                  },
                                  icon: const Icon(Icons.chat)),
                              IconButton(
                                onPressed: signUserOut,
                                icon: const Icon(Icons.logout),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text('My Products'),
                      const SizedBox(
                        height: 10,
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Number of columns
                          childAspectRatio: 2 / 3, // Aspect ratio for the items
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: productList.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot document = productList[index];
                          String productID = document.id;
                          Map<String, dynamic> data =
                              document.data() as Map<String, dynamic>;
                          String productName = data['productName'];
                          String price =
                              formatCurrency.format(data['productPrice']);

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProductPage(
                                    productID: productID,
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              child: Container(
                                margin: EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.keyboard,
                                      size: 100,
                                    ),
                                    const SizedBox(height: 10.0),
                                    Text(
                                      productName,
                                      style: const TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 5.0),
                                    Text(
                                      price,
                                      style: const TextStyle(
                                          fontSize: 16.0, color: Colors.black),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      // Add any widgets you want to display below the GridView here
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
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: MyTextField(
                                controller: itemController,
                                hintText: "Search...",
                                obscureText: false),
                          ),
                          // const Icon(Icons.search),
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
                                                const AddProductPage()));
                                  },
                                  icon: const Icon(Icons.upload)),
                              IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ListUserPage()));
                                  },
                                  icon: const Icon(Icons.chat)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Center(
                        child: Text('No Product.'),
                      )
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
