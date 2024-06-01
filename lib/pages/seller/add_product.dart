import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fp_ppb/components/big_button.dart';
import 'package:fp_ppb/service/product_service.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

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
      await productService.addProduct(
        productNameController.text,
        productDescriptionController.text,
        productCategoryController.text,
        productPriceController.text,
        productStockController.text,
        productConditionController.text,
      );
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
        title: const Text("Add Product"),
        centerTitle: true,
        backgroundColor: Colors.orangeAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              child: Column(children: [
                TextFormField(
                  controller: productNameController,
                  decoration: InputDecoration(labelText: 'Product Name'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: productCategoryController,
                  decoration: InputDecoration(labelText: 'Category'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: productPriceController,
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: productStockController,
                  decoration: InputDecoration(labelText: 'Stock'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: productDescriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: productConditionController,
                  decoration: InputDecoration(labelText: 'Condition'),
                ),
                SizedBox(height: 20),
                BigButton(
                  onTap: addProduct,
                  msg: 'Add Product',
                  color: Colors.black,
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
