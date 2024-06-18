import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fp_ppb/pages/transaction_page_detail.dart';
import 'package:fp_ppb/service/auth_service.dart';
import 'package:fp_ppb/service/order_service.dart';
import 'package:intl/intl.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  late Future<List<DocumentSnapshot>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _transactionsFuture = fetchTransactions();
  }

  Future<List<DocumentSnapshot>> fetchTransactions() async {
    return await OrderService().getUserOrders();
  }

  Future<String> getStoreName(String storeID) async {
    DocumentSnapshot storeSnapshot = await FirebaseFirestore.instance.collection('stores').doc(storeID).get();
    if (storeSnapshot.exists) {
      Map<String, dynamic> storeData = storeSnapshot.data() as Map<String, dynamic>;
      return storeData['storeName'] ?? 'Unknown Store';
    } else {
      return 'Unknown Store';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _transactionsFuture,
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
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final transaction = snapshot.data![index];
              final transactionData = transaction.data() as Map<String, dynamic>;
              final storeID = transactionData['storeID'] ?? 'Unknown Store';
              final totalAmount = transactionData['totalPrice'] ?? 0.0;
              final createdAt = (transactionData['createdAt'] as Timestamp).toDate();
              final formattedAmount = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp').format(totalAmount);
              final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(createdAt);

              return FutureBuilder<String>(
                future: getStoreName(storeID),
                builder: (context, storeSnapshot) {
                  if (storeSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: const Text('Loading store name...'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total: $formattedAmount'),
                          Text('Date: $formattedDate'),
                        ],
                      ),
                    );
                  }
                  if (storeSnapshot.hasError) {
                    return ListTile(
                      title: const Text('Error loading store name'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total: $formattedAmount'),
                          Text('Date: $formattedDate'),
                        ],
                      ),
                    );
                  }
                  final storeName = storeSnapshot.data ?? 'Unknown Store';

                  return ListTile(
                    title: Text(storeName),
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
                          builder: (context) => TransactionDetailPage(transactionId: transaction.id),
                        ),
                      ).then((_) {
                        setState(() {
                          _transactionsFuture = fetchTransactions();
                        });
                      });
                    },
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
