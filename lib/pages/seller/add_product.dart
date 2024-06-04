import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fp_ppb/components/big_button.dart';
import 'package:fp_ppb/enums/image_cloud_endpoint.dart';
import 'package:fp_ppb/enums/product_category.dart';
import 'package:fp_ppb/enums/product_condition.dart';
import 'package:fp_ppb/service/image_cloud_service.dart';
import 'package:fp_ppb/service/product_service.dart';
import 'package:image_picker/image_picker.dart';

class AddProductPage extends StatefulWidget {
  final String storeID;

  const AddProductPage({super.key, required this.storeID});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final productNameController = TextEditingController();
  final productDescriptionController = TextEditingController();
  final productPriceController = TextEditingController();
  final productStockController = TextEditingController();
  ProductCategory? selectedCategory;
  ProductCondition? selectedCondition;
  final ImageCloudService imageUploadService = ImageCloudService();


  void addProduct(String? imageUrl) async {
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
        selectedCategory.toString().split('.').last,
        productPriceController.text,
        productStockController.text,
        selectedCondition.toString().split('.').last,
        imageUrl,
      );
      String productId = productDocRef.id;
      await productService.addStoreProduct(
        widget.storeID,
        productId,
        productNameController.text,
        productPriceController.text,
        productStockController.text,
        imageUrl,
      );
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      showErrorMessage(e.code);
    }
  }

  Future<XFile?> pickImage() async {
    return await imageUploadService.pickImageFromGallery();
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
    String? imageUrl;
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
              child: Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.photo, size: 100,),
                    onPressed: () async {
                      XFile? image = await pickImage();
                      String? filename =
                      await imageUploadService.uploadImage(image!);
                      imageUrl = imageUploadService.getEndpoint(
                          ImageUploadEndpoint.getImageByFilename,
                          arg: filename);
                    },
                  ),
                  TextFormField(
                    controller: productNameController,
                    decoration: const InputDecoration(labelText: 'Product Name'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<ProductCategory>(
                    decoration: const InputDecoration(labelText: 'Category'),
                    value: selectedCategory,
                    onChanged: (ProductCategory? newValue) {
                      setState(() {
                        selectedCategory = newValue!;
                      });
                    },
                    items: ProductCategory.values.map((ProductCategory category) {
                      return DropdownMenuItem<ProductCategory>(
                        value: category,
                        child: Text(category.displayName),
                      );
                    }).toList(),
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
                  DropdownButtonFormField<ProductCondition>(
                    decoration: const InputDecoration(labelText: 'Condition'),
                    value: selectedCondition,
                    onChanged: (ProductCondition? newValue) {
                      setState(() {
                        selectedCondition = newValue!;
                      });
                    },
                    items: ProductCondition.values.map((ProductCondition condition) {
                      return DropdownMenuItem<ProductCondition>(
                        value: condition,
                        child: Text(condition.displayName),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  BigButton(
                    onTap: () => addProduct(imageUrl),
                    msg: 'Add Product',
                    color: Colors.blueAccent,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
