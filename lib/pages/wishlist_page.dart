import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fp_ppb/service/wishlist_service.dart';
import 'package:intl/intl.dart';
import '../models/wishlist.dart';
import '../pages/show_product.dart';

class WishlistPage extends StatefulWidget {
  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final WishlistService wishlistService = WishlistService();
  final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
      ),
      body: StreamBuilder<List<WishlistItem>>(
        stream: wishlistService.getWishlistStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No items in wishlist.'));
          }

          List<WishlistItem> wishlistItems = snapshot.data!;

          return ListView.builder(
            itemCount: wishlistItems.length,
            itemBuilder: (context, index) {
              WishlistItem item = wishlistItems[index];
              return ListTile(
                leading: GestureDetector(
                  onTap: () {
                    // Navigate to ShowProductPage when image is tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShowProductPage(
                          productID: item.productID,
                          storeID: item.storeID,
                        ),
                      ),
                    );
                  },
                  child: item.imageUrl != null ? Image.network(item.imageUrl!) : null,
                ),
                title: GestureDetector(
                  onTap: () {
                    // Navigate to ShowProductPage when title is tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShowProductPage(
                          productID: item.productID,
                          storeID: item.storeID,
                        ),
                      ),
                    );
                  },
                  child: Text(item.productName),
                ),
                subtitle: Text(formatCurrency.format(item.productPrice)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    wishlistService.removeFromWishlist(item.productID);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
