import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fp_ppb/service/order_service.dart';
import 'package:intl/intl.dart';

import '../service/auth_service.dart';

class TransactionDetailPage extends StatelessWidget {
  final String transactionId;

  const TransactionDetailPage({super.key, required this.transactionId});

  Future<Map<String, dynamic>> fetchTransactionDetails() async {
    final User user = AuthService().getCurrentUser()!;
    DocumentSnapshot transactionSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('orders')
        .doc(transactionId)
        .get();

    Map<String, dynamic> transactionData = transactionSnapshot.data() as Map<String, dynamic>;

    // Fetch store details
    String storeID = transactionData['storeID'];
    DocumentSnapshot storeSnapshot = await FirebaseFirestore.instance.collection('stores').doc(storeID).get();
    Map<String, dynamic> storeData = storeSnapshot.data() as Map<String, dynamic>;

    // Fetch items
    QuerySnapshot itemsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('orders')
        .doc(transactionId)
        .collection('orderItems')
        .get();
    List<Map<String, dynamic>> items = [];

    for (var itemDoc in itemsSnapshot.docs) {
      Map<String, dynamic> itemData = itemDoc.data() as Map<String, dynamic>;
      DocumentSnapshot productSnapshot = await FirebaseFirestore.instance.collection('products').doc(itemData['productID']).get();
      Map<String, dynamic> productData = productSnapshot.data() as Map<String, dynamic>;

      items.add({
        'productID': itemData['productID'],
        'quantity': itemData['quantity'],
        'productName': productData['productName'],
        'productPhoto': productData['productPhoto'],
      });
    }

    return {
      'transactionData': transactionData,
      'storeData': storeData,
      'items': items,
    };
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchTransactionDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No details found.'));
          }

          final transactionData = snapshot.data!['transactionData'];
          final storeData = snapshot.data!['storeData'];
          final items = snapshot.data!['items'];

          final storeName = storeData['storeName'] ?? 'Unknown Store';
          final storePhoto = storeData['storePhoto'] ?? ''; // Assuming you have a field for store photo
          final totalAmount = transactionData['totalPrice'] ?? 0.0;
          final formattedAmount = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp').format(totalAmount);
          final createdAt = (transactionData['createdAt'] as Timestamp).toDate();
          final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(createdAt);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (storePhoto.isNotEmpty)
                    Center(
                      child: Image.network(storePhoto, height: 100, width: 100, fit: BoxFit.cover),
                    ),
                  SizedBox(height: 10),
                  Text('Store: $storeName', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text('Total: $formattedAmount', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 10),
                  Text('Date: $formattedDate', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 20),
                  Text('Items Purchased:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        leading: item['productPhoto'] != null
                            ? Image.network(item['productPhoto'], height: 50, width: 50, fit: BoxFit.cover)
                            : null,
                        title: Text(item['productName'] ?? 'Unknown Product'),
                        subtitle: Text('Quantity: ${item['quantity']}'),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
