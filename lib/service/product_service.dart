import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fp_ppb/models/product.dart';

class ProductService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference products =
      FirebaseFirestore.instance.collection('products');

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<void> addProduct(String productName, productDescription,
      productCategory, productPrice, productStock, productCondition) {
    final Timestamp timestamp = Timestamp.now();

    final User user = getCurrentUser()!;

    Product newProduct = Product(
        sellerUid: user.uid,
        productName: productName,
        productDescription: productDescription,
        productCategory: productCategory,
        productPrice: double.parse(productPrice),
        productStock: int.parse(productStock),
        productCondition: productCondition,
        createdAt: timestamp,
        updatedAt: timestamp);

    return products.add(newProduct.toMap());
  }

  Stream<QuerySnapshot> getProductStream() {
    final productStream =
        products.orderBy('createdAt', descending: true).snapshots();

    return productStream;
  }

  Future<void> updateProduct(
      String productID,
      String productName,
      productDescription,
      productCategory,
      productPrice,
      productStock,
      productCondition,
      createdAt) {
    final Timestamp timestamp = Timestamp.now();

    final User user = getCurrentUser()!;

    Product updateProduct = Product(
        sellerUid: user.uid,
        productName: productName,
        productDescription: productDescription,
        productCategory: productCategory,
        productPrice: double.parse(productPrice),
        productStock: int.parse(productStock),
        productCondition: productCondition,
        createdAt: createdAt,
        updatedAt: timestamp);

    return products.doc(productID).update(updateProduct.toMap());
  }

  Future<void> updateProductPrice(String productID, productPrice){
    final Timestamp timestamp = Timestamp.now();
    return products.doc(productID).update({
      'productPrice': double.parse(productPrice),
      'updatedAt': timestamp
    });
  }

  Future<void> updateProductStock(String productID, productStock){
    final Timestamp timestamp = Timestamp.now();
    return products.doc(productID).update({
      'productPrice': int.parse(productStock),
      'updatedAt': timestamp
    });
  }

  Future<void> deleteProduct(String productID) {
    return products.doc(productID).delete();
  }
}
