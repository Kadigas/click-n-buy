import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fp_ppb/models/product.dart';

class ProductService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference products = FirebaseFirestore.instance.collection(
      'products');

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
        productPrice: productPrice,
        productStock: productStock,
        productCondition: productCondition,
        timestamp: timestamp
    );

    return products.add(newProduct.toMap());
  }

  Stream<QuerySnapshot> getProductStream() {
    final productStream = products.orderBy('timestamp', descending: false).snapshots();

    return productStream;
  }
}