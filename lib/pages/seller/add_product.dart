import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fp_ppb/components/big_button.dart';
import 'package:fp_ppb/service/product_service.dart';
import 'package:fp_ppb/service/store_service.dart';

class AddProductPage extends StatefulWidget {
  final String storeID;

  const AddProductPage({super.key, required this.storeID});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final productNameController = TextEditingController();
  final productDescriptionController = TextEditingController();
  final productCategoryController = TextEditingController();
  final productPriceController = TextEditingController();
  final productStockController = TextEditingController();
  final productConditionController = TextEditingController();

  void addProduct() async {
    final productService = ProductService();
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });

    try {
      DocumentReference productDocRef = await productService.addProduct(
        widget.storeID,
        productNameController.text,
        productDescriptionController.text,
        productCategoryController.text,
        productPriceController.text,
        productStockController.text,
        productConditionController.text,
      );
      String productId = productDocRef.id;
      await productService.addStoreProduct(
        widget.storeID,
        productId,
        productNameController.text,
        productPriceController.text,
        productStockController.text,
      );
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
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add Product",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
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
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              child: Column(children: [
                TextFormField(
                  controller: productNameController,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: productCategoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: productPriceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: productStockController,
                  decoration: const InputDecoration(labelText: 'Stock'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: productDescriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: productConditionController,
                  decoration: const InputDecoration(labelText: 'Condition'),
                ),
                const SizedBox(height: 20),
                BigButton(
                  onTap: () => addProduct(),
                  msg: 'Add Product',
                  color: Colors.blueAccent,
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
