import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fp_ppb/models/wishlist.dart';
import 'package:fp_ppb/service/auth_service.dart';

class WishlistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _auth = AuthService();

  Future<void> addToWishlist(String storeID, String productID, String productName, double productPrice, {String? imageUrl}) async {
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

      DocumentSnapshot wishlistSnapshot = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('wishlist')
          .doc(productID)
          .get();

      if (wishlistSnapshot.exists) {
        throw Exception('Product already in wishlist');
      }

      WishlistItem newItem = WishlistItem(
        storeID: storeID,
        productID: productID,
        productName: productName,
        productPrice: productPrice,
        imageUrl: imageUrl,
        createdAt: timestamp,
        updatedAt: timestamp,
      );

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('wishlist')
          .doc(productID)
          .set(newItem.toMap());
    } catch (e) {
      throw Exception('Failed to add to wishlist: $e');
    }
  }

  Stream<List<WishlistItem>> getWishlistStream() {
    final currentUser = _auth.getCurrentUser();
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    return _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('wishlist')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return WishlistItem.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<void> removeFromWishlist(String productID) async {
    final currentUser = _auth.getCurrentUser();
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('wishlist')
          .doc(productID)
          .delete();
    } catch (e) {
      throw Exception('Failed to remove from wishlist: $e');
    }
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
}
