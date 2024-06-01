import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fp_ppb/components/my_textfield.dart';
import 'package:fp_ppb/pages/chat_page.dart';
import 'package:fp_ppb/pages/list_user_page.dart';
import 'package:fp_ppb/pages/seller/add_product.dart';
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
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: productList.map((document) {
                            String docID = document.id;
                            Map<String, dynamic> data =
                                document.data() as Map<String, dynamic>;
                            String productName = data['productName'];
                            String price = data['productPrice'];

                            return Card(
                              child: Container(
                                width: 200.0,
                                // Set the width of each card as needed
                                margin: EdgeInsets.all(8.0),
                                // Add some margin between cards
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.keyboard,
                                      size: 100,
                                    ),
                                    const SizedBox(height: 10.0),
                                    // Space between icon and text
                                    Text(
                                      productName,
                                      style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 5.0),
                                    // Space between productName and price
                                    Text(
                                      'Rp${price.toString()}',
                                      style: TextStyle(
                                          fontSize: 16.0, color: Colors.grey),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed: () {},
                                          icon: const Icon(Icons.edit),
                                        ),
                                        IconButton(
                                          onPressed: () {},
                                          icon: const Icon(Icons.delete),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      // Add any widgets you want to display below the ListView here
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
