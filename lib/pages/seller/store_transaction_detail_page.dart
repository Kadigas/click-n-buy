import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../service/auth_service.dart';

class TransactionDetailPage extends StatelessWidget {
  final String transactionId;

  const TransactionDetailPage({Key? key, required this.transactionId}) : super(key: key);

  Future<Map<String, dynamic>> fetchTransactionDetails() async {
    final User user = AuthService().getCurrentUser()!;
    DocumentSnapshot transactionSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('orders')
        .doc(transactionId)
        .get();

    return transactionSnapshot.data() as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction Details'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchTransactionDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: Text('No details found.'));
          }

          final transactionData = snapshot.data!;
          final storeId = transactionData['storeID'];
          final totalAmount = transactionData['totalPrice'] ?? 0.0;
          final formattedAmount = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp').format(totalAmount);
          final createdAt = (transactionData['createdAt'] as Timestamp).toDate();
          final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(createdAt);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('stores').doc(storeId).get(),
                  builder: (context, storeSnapshot) {
                    if (storeSnapshot.connectionState == ConnectionState.waiting) {
                      return Text('Loading store name...');
                    }
                    if (storeSnapshot.hasError) {
                      return Text('Error loading store name: ${storeSnapshot.error}');
                    }
                    if (!storeSnapshot.hasData || !storeSnapshot.data!.exists) {
                      return Text('Store not found.');
                    }

                    final storeData = storeSnapshot.data!;
                    final storeName = storeData['storeName'] ?? 'Unknown Store';
                    final storePhotoUrl = storeData['storePhotoUrl'] ?? '';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Store: $storeName', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        if (storePhotoUrl.isNotEmpty)
                          Image.network(
                            storePhotoUrl,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        SizedBox(height: 10),
                        Text('Total: $formattedAmount', style: TextStyle(fontSize: 16)),
                        SizedBox(height: 10),
                        Text('Date: $formattedDate', style: TextStyle(fontSize: 16)),
                        SizedBox(height: 20),
                      ],
                    );
                  },
                ),
                Divider(),
                Text(
                  'Items Purchased:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(AuthService().getCurrentUser()!.uid)
                        .collection('orders')
                        .doc(transactionId)
                        .collection('orderItems')
                        .get(),
                    builder: (context, itemsSnapshot) {
                      if (itemsSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (itemsSnapshot.hasError) {
                        return Center(child: Text('Error: ${itemsSnapshot.error}'));
                      }
                      if (!itemsSnapshot.hasData || itemsSnapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No items found.'));
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: itemsSnapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final item = itemsSnapshot.data!.docs[index];
                          final itemData = item.data() as Map<String, dynamic>;
                          final productName = itemData['productName'] ?? 'Unknown Product';
                          final productPhotoUrl = itemData['productPhotoUrl'] ?? '';

                          return ListTile(
                            leading: productPhotoUrl.isNotEmpty
                                ? CircleAvatar(
                              backgroundImage: NetworkImage(productPhotoUrl),
                            )
                                : Icon(Icons.shopping_bag),
                            title: Text(productName),
                            subtitle: Text('Quantity: ${itemData['quantity']}'),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
