import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fp_ppb/components/image_product.dart';
import 'package:fp_ppb/components/my_textfield.dart';
import 'package:fp_ppb/pages/cart_page.dart';
import 'package:fp_ppb/pages/list_user_page.dart';
import 'package:fp_ppb/pages/show_product.dart';
import 'package:fp_ppb/service/auth_service.dart';
import 'package:fp_ppb/service/product_service.dart';
import 'package:fp_ppb/service/store_service.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  final itemController = TextEditingController();
  final ProductService productService = ProductService();
  final StoreService storeService = StoreService();
  final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');

  void signUserOut() {
    final authService = AuthService();
    authService.signOut();
  }

  void showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout?'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                signUserOut();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: productService.getProductStream(),
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
                                    MaterialPageRoute(builder: (context) => const CartPage()),
                                  );
                                },
                                icon: const Icon(Icons.shopping_cart),
                              ),
                              IconButton(
                                onPressed: showSignOutDialog,
                                icon: const Icon(Icons.logout),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ListUserPage()),
                              );
                            },
                            icon: const Icon(Icons.chat),
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
                                  MaterialPageRoute(builder: (context) => const CartPage()),
                                );
                              },
                              icon: const Icon(Icons.shopping_cart),
                            ),
                            IconButton(
                              onPressed: showSignOutDialog,
                              icon: const Icon(Icons.logout),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ListUserPage()),
                            );
                          },
                          icon: const Icon(Icons.chat),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Featured Products',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: productList.length,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.55,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemBuilder: (context, index) {
                        DocumentSnapshot document = productList[index];
                        String productID = document.id;
                        Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                        String productName = data['productName'];
                        double productPrice = data['productPrice'];
                        String storeID = data['storeID'];
                        String? imageUrl = data['imageUrl'];
                        String price = formatCurrency.format(productPrice);

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ShowProductPage(
                                  productID: productID,
                                  storeID: storeID,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: ImageProduct(imageUrl: imageUrl),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 10, 5, 5),
                                      child: Text(
                                        productName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 2, 2, 2),
                                      child: Text(
                                        price,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    FutureBuilder<String>(
                                      future:
                                      storeService.getStoreName(storeID),
                                      builder: (context, storeSnapshot) {
                                        if (storeSnapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                              child:
                                              CircularProgressIndicator());
                                        }
                                        if (storeSnapshot.hasError) {
                                          return Center(
                                              child: Text(
                                                  'Error: ${storeSnapshot.error}'));
                                        }
                                        return Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 2, 2, 2),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.storefront,
                                                size: 16,
                                              ),
                                              const SizedBox(
                                                width: 2,
                                              ),
                                              Text(
                                                storeSnapshot.data ??
                                                    'Unknown Store',
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(
                                      height: 35,
                                    ),
                                  ],
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.more_horiz),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(
                      height: 30,
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
