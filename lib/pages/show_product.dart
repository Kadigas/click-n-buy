import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fp_ppb/components/my_button.dart';
import 'package:fp_ppb/enums/product_category.dart';
import 'package:fp_ppb/enums/product_condition.dart';
import 'package:fp_ppb/service/cart_service.dart';
import 'package:fp_ppb/pages/chat/chat_page.dart';
import 'package:fp_ppb/service/auth_service.dart';
import 'package:fp_ppb/service/enum_service.dart';
import 'package:fp_ppb/service/product_service.dart';
import 'package:intl/intl.dart';
import '../components/image_product.dart';
import '../service/wishlist_service.dart';

class ShowProductPage extends StatefulWidget {
  final String productID;
  final String storeID;

  const ShowProductPage(
      {super.key, required this.productID, required this.storeID});

  @override
  State<ShowProductPage> createState() => _ShowProductPageState();
}

class _ShowProductPageState extends State<ShowProductPage> {
  late Future<DocumentSnapshot> _document;
  late Future<DocumentSnapshot> _storeDocument;
  final ProductService productService = ProductService();
  final EnumService enumService = EnumService();
  final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    _document = FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productID)
        .get();
    _storeDocument = FirebaseFirestore.instance
        .collection('stores')
        .doc(widget.storeID)
        .get();
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

  Future<void> addToCart(String storeID, productID,
      productMinimumQuantity) async {
    final cartService = CartService();
    _loadingState();

    try {
      await cartService.addToCart(
        storeID,
        productID,
        productMinimumQuantity,
      );
      Navigator.of(context, rootNavigator: true).pop();
    } on FirebaseAuthException catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      showErrorMessage(e.code);
    }
  }

  Future<void> addToWishlist(String storeID, String productID,
      String productMinimumQuantity) async {
    final wishlistService = WishlistService();
    _loadingState();

    try {
      // Fetch additional product details
      DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(productID)
          .get();
      if (!productSnapshot.exists) {
        throw Exception('Product not found');
      }

      String productName = productSnapshot['productName'];
      double productPrice = productSnapshot['productPrice'];
      String? imageUrl = productSnapshot['imageUrl'];

      // Add to wishlist
      await wishlistService.addToWishlist(
        storeID,
        productID,
        productName,
        productPrice,
        imageUrl: imageUrl,
      );

      Navigator.of(context, rootNavigator: true).pop();
    } on FirebaseAuthException catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      showErrorMessage(e.code);
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      showErrorMessage('Failed to add to wishlist: $e');
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
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
      body: FutureBuilder<DocumentSnapshot>(
        future: _document,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Document not found'));
          }

          Map<String, dynamic> data =
          snapshot.data!.data() as Map<String, dynamic>;
          String productName = data['productName'];
          String productDescription = data['productDescription'];
          String? imageUrl = data['imageUrl'];
          ProductCategory productCategory =
          enumService.parseProductCategory(data['productCategory']);
          String productPrice = formatCurrency.format(data['productPrice']);
          int productStock = data['productStock'];
          String productMinimumQuantity =
          data['productMinimumQuantity'].toString();
          ProductCondition productCondition =
          enumService.parseProductCondition(data['productCondition']);

          return FutureBuilder<DocumentSnapshot>(
            future: _storeDocument,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(child: Text('Document not found'));
              }

              Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
              String storeName = data['storeName'];
              String storeId = snapshot.data!.id.toString();
              String sellerUid = data['sellerUid'];

              return Stack(
                children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 80.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                        Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 25.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            SizedBox(
                            width: 380,
                            height: 300,
                            child: Center(
                                child:
                                ImageProduct(imageUrl: imageUrl)),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            productPrice,
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            productName,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 10),
                          const Divider(
                            thickness: 1.0,
                            color: Colors.grey,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            'Product Details',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                              'Category: ${productCategory.displayName}'),
                          const SizedBox(height: 10),
                          Text(
                              'Condition: ${productCondition.displayName}'),
                          const SizedBox(
                            height: 10,
                          ),
                          Text('Stock: $productStock'),
                          const SizedBox(
                            height: 10,
                          ),
                          productStock > 0
                              ? Text(
                              'Minimum purchase: $productMinimumQuantity')
                              : const Text(
                            'This product is unavailable to purchase due to out of stock.',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Divider(
                          thickness: 1.0,
                          color: Colors.grey,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          'Product Description',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(productDescription),
                        const SizedBox(
                          height: 10,
                        ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          25.0, 25.0, 25.0, 25),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.account_circle,
                            size: 50,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            storeName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                ],
              ),
              ),
              ),
              Positioned(
              bottom: 5,
              left: 0,
              right: 0,
              child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(
              color: Colors.grey,
              width: 1.0,
              ),
              borderRadius: BorderRadius.circular(8)),
              child: Center(
              child: IconButton(
              onPressed: () {
              Navigator.push(
              context,
              MaterialPageRoute(
              builder: (context) => ChatPage(
              showName: storeName,
              userId: _authService
                  .getCurrentUser()!
                  .uid,
              otherUserId: sellerUid,
              isSeller: false,
              storeId: storeId,
              )));
              },
              icon: const Icon(Icons.message))),
              ),
              const SizedBox(
              width: 5,
              ),
              productStock > 0
              ? MyButton(
              msg: 'Add to Cart',
              color: Colors.black,
              onTap: () async {
              await addToCart(
              widget.storeID,
              widget.productID,
              productMinimumQuantity);
              ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
              content:
              Text('Succeeded add to cart!')),
              );
              },
              )
                  : MyButton(
              onTap: () {},
              msg: 'Add to Cart',
              color: Colors.grey),
              const SizedBox(
              width: 3,
              ),
              MyButton(
              msg: 'Add to Wishlist',
              color: Colors.redAccent,
              onTap: () async {
              await addToWishlist(widget.storeID,
              widget.productID, productMinimumQuantity);
              ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
              content:
              Text('Succeeded add to wishlist!')),
              );
              },
              )
              ],
              ),
              ),
              ),
              ]
              ,
              );
            },
          );
        },
      ),
    );
  }
}
