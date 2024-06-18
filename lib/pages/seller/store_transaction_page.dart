import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../transaction_page_detail.dart';

class StoreTransactionPage extends StatelessWidget {
  final String storeId; // Add storeId to the constructor

  const StoreTransactionPage({super.key, required this.storeId});

  Future<List<Map<String, dynamic>>> fetchStoreTransactions() async {
    List<Map<String, dynamic>> transactions = [];
    QuerySnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').get();

    for (var userDoc in userSnapshot.docs) {
      QuerySnapshot orderSnapshot = await userDoc.reference.collection('orders').where('storeID', isEqualTo: storeId).get();
      for (var orderDoc in orderSnapshot.docs) {
        Map<String, dynamic> orderData = orderDoc.data() as Map<String, dynamic>;
        orderData['orderId'] = orderDoc.id;
        transactions.add(orderData);
      }
    }
    return transactions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Transactions'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchStoreTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No transactions found.'));
          }

          List<Map<String, dynamic>> transactions = snapshot.data!;
          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> transaction = transactions[index];
              final totalAmount = transaction['totalPrice'] ?? 0.0;
              final formattedAmount = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp').format(totalAmount);
              final createdAt = (transaction['createdAt'] as Timestamp).toDate();
              final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(createdAt);

              return ListTile(
                title: Text('Order ID: ${transaction['orderId']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total: $formattedAmount'),
                    Text('Date: $formattedDate'),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransactionDetailPage(transactionId: transaction['orderId']),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
