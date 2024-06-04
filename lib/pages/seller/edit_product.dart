import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fp_ppb/components/big_button.dart';
import 'package:fp_ppb/components/image_product.dart';
import 'package:fp_ppb/enums/image_cloud_endpoint.dart';
import 'package:fp_ppb/enums/product_category.dart';
import 'package:fp_ppb/enums/product_condition.dart';
import 'package:fp_ppb/service/image_cloud_service.dart';
import 'package:fp_ppb/service/product_service.dart';
import 'package:image_picker/image_picker.dart';

class EditProductPage extends StatefulWidget {
  final String productID;
  final String storeID;

  const EditProductPage(
      {super.key, required this.productID, required this.storeID});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  late Future<DocumentSnapshot> _document;
  late Timestamp createdAt;
  late String storeId;
  final productNameController = TextEditingController();
  final productDescriptionController = TextEditingController();
  final productPriceController = TextEditingController();
  final productStockController = TextEditingController();
  ProductCategory? selectedCategory;
  ProductCondition? selectedCondition;
  String? imageUrl;
  final ImageCloudService imageUploadService = ImageCloudService();

  ProductCategory? getCategoryFromString(String category) {
    switch (category) {
      case 'electronics':
        return ProductCategory.electronics;
      case 'fashion':
        return ProductCategory.fashion;
      case 'home':
        return ProductCategory.home;
      case 'beauty':
        return ProductCategory.beauty;
      case 'sports':
        return ProductCategory.sports;
      case 'toys':
        return ProductCategory.toys;
      default:
        return null;
    }
  }

  ProductCondition? getConditionFromString(String condition) {
    switch (condition) {
      case 'brandNew':
        return ProductCondition.brandNew;
      case 'used':
        return ProductCondition.used;
      case 'refurbished':
        return ProductCondition.refurbished;
      default:
        return null;
    }
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

  void editProduct(String? imageUrl) async {
    final productService = ProductService();
    _loadingState();

    try {
      await productService.updateProduct(
        widget.productID,
        widget.storeID,
        productNameController.text,
        productDescriptionController.text,
        selectedCategory.toString().split('.').last,
        productPriceController.text,
        productStockController.text,
        selectedCondition.toString().split('.').last,
        imageUrl,
        createdAt,
      );
      await productService.updateStoreProduct(
        widget.productID,
        widget.storeID,
        productNameController.text,
        productPriceController.text,
        productStockController.text,
        imageUrl,
        createdAt,
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
  void initState() {
    super.initState();
    _document = FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productID)
        .get();
    _document.then((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        productNameController.text = data['productName'];
        productDescriptionController.text = data['productDescription'];
        productPriceController.text = data['productPrice'].toInt().toString();
        productStockController.text = data['productStock'].toString();
        selectedCategory = getCategoryFromString(data['productCategory']);
        selectedCondition = getConditionFromString(data['productCondition']);
        imageUrl = data['imageUrl'];
        createdAt = data['createdAt'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Edit Product", style: TextStyle(color: Colors.white)),
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

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                child: Column(
                  children: [
                    imageUrl != null
                        ? Column(
                            children: [
                              Stack(
                                children: [
                                  Center(
                                    child: SizedBox(
                                      width: 200,
                                      child: ImageProduct(imageUrl: imageUrl),
                                    ),
                                  ),
                                  Positioned(
                                    top: -12,
                                    right: 68,
                                    child: IconButton(
                                      icon: const Icon(Icons.close_rounded),
                                      onPressed: () {
                                        setState(
                                          () {
                                            imageUrl = null;
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.add_photo_alternate,
                                  size: 180,
                                ),
                                onPressed: () async {
                                  XFile? image = await pickImage();
                                  if (image != null) {
                                    _loadingState();
                                    String? filename = await imageUploadService
                                        .uploadImage(image!);
                                    Navigator.of(context, rootNavigator: true)
                                        .pop();
                                    setState(
                                      () {
                                        imageUrl =
                                            imageUploadService.getEndpoint(
                                                ImageUploadEndpoint
                                                    .getImageByFilename,
                                                arg: filename);
                                      },
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                    TextFormField(
                      controller: productNameController,
                      decoration:
                          const InputDecoration(labelText: 'Product Name'),
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
                      items: ProductCategory.values
                          .map((ProductCategory category) {
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
                      decoration:
                          const InputDecoration(labelText: 'Description'),
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
                      items: ProductCondition.values
                          .map((ProductCondition condition) {
                        return DropdownMenuItem<ProductCondition>(
                          value: condition,
                          child: Text(condition.displayName),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    BigButton(
                      onTap: () {
                        editProduct(imageUrl);
                      },
                      color: Colors.blueAccent,
                      msg: 'Save Changes',
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

  @override
  void dispose() {
    productNameController.dispose();
    productPriceController.dispose();
    super.dispose();
  }
}
