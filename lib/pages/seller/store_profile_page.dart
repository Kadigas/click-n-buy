import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StoreProfilePage extends StatefulWidget {
  const StoreProfilePage({super.key});

  @override
  State<StoreProfilePage> createState() => _StoreProfilePageState();
}

class _StoreProfilePageState extends State<StoreProfilePage> {
  late Future<QuerySnapshot> _storeDocuments;

  @override
  void initState() {
    super.initState();
    String uid = FirebaseAuth.instance.currentUser!.uid;
    _storeDocuments = FirebaseFirestore.instance
        .collection('stores')
        .where('sellerUid', isEqualTo: uid)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Store Profile"),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _storeDocuments,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No store found'));
          }

          var data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
          String storeName = data['storeName'];

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.account_circle,
                                size: 125,
                              ),
                              const SizedBox(
                                width: 25,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    storeName,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                              const SizedBox(
                                width: 25,
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.settings),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
