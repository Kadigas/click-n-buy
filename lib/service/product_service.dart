import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fp_ppb/models/product.dart';
import 'package:fp_ppb/models/store_product.dart';

class ProductService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference products =
      FirebaseFirestore.instance.collection('products');

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<DocumentReference> addProduct(
      String storeID,
      productName,
      productDescription,
      productCategory,
      productPrice,
      productStock,
      productCondition,
      productWeight,
      productMinimumQuantity,
      String? imageUrl) {
    final Timestamp timestamp = Timestamp.now();

    Product newProduct = Product(
        storeID: storeID,
        productName: productName,
        productDescription: productDescription,
        productCategory: productCategory,
        productPrice: double.parse(productPrice),
        productStock: int.parse(productStock),
        productCondition: productCondition,
        productWeight: double.parse(productWeight) ?? 1000,
        productMinimumQuantity: int.parse(productMinimumQuantity) ?? 1,
        imageUrl: imageUrl ?? "",
        createdAt: timestamp,
        updatedAt: timestamp);

    final productDoc = products.add(newProduct.toMap());

    return productDoc;
  }

  Stream<QuerySnapshot> getProductStream() {
    final productStream =
        products.orderBy('createdAt', descending: true).snapshots();

    return productStream;
  }

  Future<Map<String, dynamic>> getProductDetails(String productID) async {
    try {
      DocumentSnapshot productSnapshot =
          await _firestore.collection('products').doc(productID).get();
      if (productSnapshot.exists) {
        return productSnapshot.data() as Map<String, dynamic>;
      } else {
        throw Exception("Product not found");
      }
    } catch (e) {
      throw Exception("Failed to get product details: $e");
    }
  }

  Future<void> updateProduct(
    String productID,
    storeID,
    productName,
    productDescription,
    productCategory,
    productPrice,
    productStock,
    productCondition,
    productWeight,
    productMinimumQuantity,
    String? imageUrl,
    Timestamp createdAt,
  ) {
    final Timestamp timestamp = Timestamp.now();

    Product updateProduct = Product(
      storeID: storeID,
      productName: productName,
      productDescription: productDescription,
      productCategory: productCategory,
      productPrice: double.parse(productPrice),
      productStock: int.parse(productStock),
      productCondition: productCondition,
      productWeight: double.parse(productWeight) ?? 100,
      productMinimumQuantity: int.parse(productMinimumQuantity) ?? 1,
      imageUrl: imageUrl ?? "",
      createdAt: createdAt,
      updatedAt: timestamp,
    );

    return products.doc(productID).update(updateProduct.toMap());
  }

  Future<void> updateProductPrice(String productID, productPrice) {
    final Timestamp timestamp = Timestamp.now();
    return products.doc(productID).update(
        {'productPrice': double.parse(productPrice), 'updatedAt': timestamp});
  }

  Future<void> updateProductStock(String productID, productStock) {
    final Timestamp timestamp = Timestamp.now();
    return products.doc(productID).update(
        {'productStock': int.parse(productStock), 'updatedAt': timestamp});
  }

  Future<void> deleteProduct(String productID) {
    return products.doc(productID).delete();
  }

  Stream<QuerySnapshot> getStoreProductStream(String storeID) {
    final productStream = _firestore
        .collection('stores')
        .doc(storeID)
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return productStream;
  }

  Future<Map<String, dynamic>> getStoreProduct(
      String storeID, String productID) async {
    DocumentSnapshot productDoc = await _firestore
        .collection('stores')
        .doc(storeID)
        .collection('products')
        .doc(productID)
        .get();
    return productDoc.data() as Map<String, dynamic>? ?? {};
  }

  Future<void> addStoreProduct(String storeID, productID, productName,
      productPrice, productStock, String? imageUrl) {
    final Timestamp timestamp = Timestamp.now();

    StoreProduct newProduct = StoreProduct(
        productName: productName,
        productPrice: double.parse(productPrice),
        productStock: int.parse(productStock),
        createdAt: timestamp,
        updatedAt: timestamp);

    return _firestore
        .collection('stores')
        .doc(storeID)
        .collection('products')
        .doc(productID)
        .set(newProduct.toMap());
  }

  Future<void> updateStoreProduct(String productID, storeID, productName,
      productPrice, productStock, String? imageUrl, Timestamp createdAt) {
    final Timestamp timestamp = Timestamp.now();

    StoreProduct updateProduct = StoreProduct(
      productName: productName,
      productPrice: double.parse(productPrice),
      productStock: int.parse(productStock),
      imageUrl: imageUrl ?? "",
      createdAt: createdAt,
      updatedAt: timestamp,
    );

    return _firestore
        .collection('stores')
        .doc(storeID)
        .collection('products')
        .doc(productID)
        .set(updateProduct.toMap());
  }

  Future<void> updateStoreProductPrice(
      String storeID, productID, productPrice) {
    final Timestamp timestamp = Timestamp.now();
    return _firestore
        .collection('stores')
        .doc(storeID)
        .collection('products')
        .doc(productID)
        .update({
      'productPrice': double.parse(productPrice),
      'updatedAt': timestamp
    });
  }

  Future<void> updateStoreProductStock(
      String storeID, productID, productStock) {
    final Timestamp timestamp = Timestamp.now();
    return _firestore
        .collection('stores')
        .doc(storeID)
        .collection('products')
        .doc(productID)
        .update(
            {'productStock': int.parse(productStock), 'updatedAt': timestamp});
  }

  Future<void> deleteStoreProduct(String storeID, productID) {
    return _firestore
        .collection('stores')
        .doc(storeID)
        .collection('products')
        .doc(productID)
        .delete();
  }

  Future<double> getProductPrice(String productID) async {
    try {
      DocumentSnapshot productSnapshot =
          await _firestore.collection('products').doc(productID).get();
      if (productSnapshot.exists) {
        Map<String, dynamic> productData =
            productSnapshot.data() as Map<String, dynamic>;
        return productData['productPrice']?.toDouble() ?? 0.0;
      } else {
        throw Exception('Product not found');
      }
    } catch (e) {
      throw Exception('Failed to get product price: $e');
    }
  }

  Future<int> getProductStock(String productID) async {
    try {
      DocumentSnapshot productSnapshot =
          await _firestore.collection('products').doc(productID).get();
      if (productSnapshot.exists) {
        Map<String, dynamic> productData =
            productSnapshot.data() as Map<String, dynamic>;
        return productData['productStock'] ?? 0;
      } else {
        throw Exception("Product not found");
      }
    } catch (e) {
      throw Exception("Failed to get product stock: $e");
    }
  }
}
