import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fp_ppb/models/cart.dart';
import 'package:fp_ppb/service/auth_service.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _auth = AuthService();

  Future<void> addToCart(String storeID, String productID) async {
    late int qty;
    late Timestamp createdAt;

    final currentUser = _auth.getCurrentUser();

    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    final Timestamp timestamp = Timestamp.now();

    try {
      DocumentSnapshot productSnapshot =
          await _firestore.collection('products').doc(productID).get();

      if (!productSnapshot.exists) {
        throw Exception('Product not found');
      }

      Map<String, dynamic> productData =
          productSnapshot.data() as Map<String, dynamic>;
      int stock = productData['productStock'];

      if (stock < 1) {
        throw Exception('Insufficient stock');
      }

      DocumentSnapshot cartSnapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('cart')
          .doc(productID)
          .get();

      if (!cartSnapshot.exists) {
        qty = 1;
        createdAt = timestamp;
      } else {
        Map<String, dynamic> cartData =
            cartSnapshot.data() as Map<String, dynamic>;
        qty = cartData['quantity'] + 1;
        createdAt = cartData['createdAt'];
      }

      Cart newProduct = Cart(
        storeID: storeID,
        productID: productID,
        quantity: qty,
        isChecked: true,
        createdAt: createdAt,
        updatedAt: timestamp,
      );

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('cart')
          .doc(productID)
          .set(newProduct.toMap());
    } catch (e) {
      throw Exception('Failed to add to cart: $e');
    }
  }

  Stream<Map<String, List<DocumentSnapshot>>> getGroupedCartStream() {
    final currentUser = _auth.getCurrentUser();
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    return _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('cart')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      Map<String, List<DocumentSnapshot>> groupedCartItems = {};
      for (var item in snapshot.docs) {
        String storeID = (item.data() as Map<String, dynamic>)['storeID'];
        if (groupedCartItems.containsKey(storeID)) {
          groupedCartItems[storeID]!.add(item);
        } else {
          groupedCartItems[storeID] = [item];
        }
      }
      return groupedCartItems;
    });
  }

  Future<String> getStoreName(String storeID) async {
    try {
      DocumentSnapshot storeSnapshot = await _firestore.collection('stores').doc(storeID).get();
      if (storeSnapshot.exists) {
        Map<String, dynamic> storeData = storeSnapshot.data() as Map<String, dynamic>;
        return storeData['storeName'] ?? 'Unknown Store';
      } else {
        return 'Unknown Store';
      }
    } catch (e) {
      return 'Unknown Store';
    }
  }

  Future<double> getPriceForProduct(String productID) async {
    DocumentSnapshot document =
    await _firestore.collection('products').doc(productID).get();
    return (document.data() as Map<String, dynamic>?)?['productPrice'] ??
        0.0;
  }

  Future<void> updateCartCheckedState(String productID, bool isChecked) async {
    final currentUser = _auth.getCurrentUser();
    await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('cart')
        .doc(productID)
        .update({'isChecked': isChecked});
  }

  Future<void> updateCartQuantity(String productID, int newQuantity) async {
    final currentUser = _auth.getCurrentUser();
    await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('cart')
        .doc(productID)
        .update({'quantity': newQuantity});
  }

  Future<void> deleteCartProduct(String productID) {
    final currentUser = _auth.getCurrentUser();
    return _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('cart')
        .doc(productID)
        .delete();
  }

  Future<Map<String, dynamic>> getStoreDetails(String storeID) async {
    final storeSnapshot = await FirebaseFirestore.instance.collection('stores').doc(storeID).get();
    if (storeSnapshot.exists) {
      return storeSnapshot.data() as Map<String, dynamic>;
    } else {
      throw Exception('Store not found');
    }
  }
}
