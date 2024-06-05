import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fp_ppb/components/image_product.dart';
import 'package:fp_ppb/components/my_button.dart';
import 'package:fp_ppb/enums/product_category.dart';
import 'package:fp_ppb/enums/product_condition.dart';
import 'package:fp_ppb/pages/seller/edit_product.dart';
import 'package:fp_ppb/service/enum_service.dart';
import 'package:fp_ppb/service/product_service.dart';
import 'package:intl/intl.dart';

class StoreShowProductPage extends StatefulWidget {
  final String productID;

  final String storeID;

  const StoreShowProductPage(
      {super.key, required this.productID, required this.storeID});

  @override
  State<StoreShowProductPage> createState() => _StoreShowProductPageState();
}

class _StoreShowProductPageState extends State<StoreShowProductPage> {
  late Future<DocumentSnapshot> _document;
  final ProductService productService = ProductService();
  final EnumService enumService = EnumService();
  final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');

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
  }

  void deleteProduct() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    try {
      await productService.deleteProduct(widget.productID);
      await productService.deleteStoreProduct(widget.storeID, widget.productID);
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      showErrorMessage(e.code);
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
          ProductCategory productCategory =
              enumService.parseProductCategory(data['productCategory']);
          String productPrice = formatCurrency.format(data['productPrice']);
          String productStock = data['productStock'].toString();
          String? imageUrl = data['imageUrl'];
          ProductCondition productCondition =
              enumService.parseProductCondition(data['productCondition']);

          return SafeArea(
            child: SingleChildScrollView(
              child: Container(
                decoration: const BoxDecoration(color: Colors.white),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Center(child: ImageProduct(imageUrl: imageUrl)),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        productPrice,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        productName,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      const Divider(
                        thickness: 1.0,
                        color: Colors.grey,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      const Text(
                        'Product Details',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text('Category: ${productCategory.displayName}'),
                      const SizedBox(
                        height: 5,
                      ),
                      Text('Condition: ${productCondition.displayName}'),
                      const SizedBox(
                        height: 5,
                      ),
                      Text('Stock: $productStock'),
                      const SizedBox(
                        height: 5,
                      ),
                      const Divider(
                        thickness: 1.0,
                        color: Colors.grey,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      const Text(
                        'Product Description',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(productDescription),
                      const SizedBox(
                        height: 35,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MyButton(
                            msg: 'Edit Product',
                            color: Colors.black,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProductPage(
                                    productID: widget.productID,
                                    storeID: widget.storeID,
                                  ),
                                ),
                              );
                              _fetchData();
                            },
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          MyButton(
                            msg: 'Delete Product',
                            color: Colors.red,
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Confirmation'),
                                    content: const Text(
                                        'Are you sure you want to proceed?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          deleteProduct();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Succeeded delete product!')),
                                          );
                                        },
                                        child: const Text('Confirm'),
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
            ),
          );
        },
      ),
    );
  }
}
