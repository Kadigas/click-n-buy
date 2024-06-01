import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fp_ppb/components/my_textfield.dart';
import 'package:fp_ppb/components/my_button.dart';
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
          child: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const SizedBox(height: 10),
              MyTextField(
                controller: productNameController,
                hintText: 'Name',
                obscureText: false,
              ),
              const SizedBox(height: 10),
              MyTextField(
                controller: productDescriptionController,
                hintText: 'Description',
                obscureText: false,
              ),
              const SizedBox(height: 10),
              MyTextField(
                controller: productCategoryController,
                hintText: 'Category',
                obscureText: false,
              ),
              const SizedBox(height: 10),
              MyTextField(
                controller: productConditionController,
                hintText: 'Condition',
                obscureText: false,
              ),
              const SizedBox(height: 10),
              MyTextField(
                controller: productPriceController,
                hintText: 'Price',
                obscureText: false,
              ),
              const SizedBox(height: 10),
              MyTextField(
                controller: productStockController,
                hintText: 'Stock',
                obscureText: false,
              ),
              const SizedBox(height: 25),
              MyButton(
                onTap: addProduct,
                msg: 'Add Product',
                color: Colors.black,
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
