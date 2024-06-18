import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fp_ppb/components/image_product.dart';
import 'package:fp_ppb/components/transparent_button.dart';
import 'package:fp_ppb/pages/seller/store_edit_profile_page.dart';
import 'package:fp_ppb/pages/seller/store_product_page.dart';
import 'package:fp_ppb/pages/seller/store_transaction_page.dart';
import 'package:fp_ppb/service/location_cloud_service.dart';

class StoreProfilePage extends StatefulWidget {
  const StoreProfilePage({super.key});

  @override
  State<StoreProfilePage> createState() => _StoreProfilePageState();
}

class _StoreProfilePageState extends State<StoreProfilePage> {
  late Future<QuerySnapshot> _document;
  late String uid;
  final locationCloudService = LocationCloudService();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    uid = FirebaseAuth.instance.currentUser!.uid;
    _document = FirebaseFirestore.instance
        .collection('stores')
        .where('sellerUid', isEqualTo: uid)
        .get();
  }

  Future<String?> _getCityName(String provinceId, String cityId) async {
    try {
      return await locationCloudService.getCityName(provinceId, cityId);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Store Profile", style: TextStyle(color: Colors.white),),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.greenAccent],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _document,
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
          String provinceId = data['province'];
          String cityId = data['city'];
          String? imageUrl = data['imageUrl'];
          String storeID = snapshot.data!.docs.first.id;

          return FutureBuilder<String?>(
            future: _getCityName(provinceId, cityId),
            builder: (context, citySnapshot) {
              if (citySnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (citySnapshot.hasError) {
                return Center(child: Text('Error: ${citySnapshot.error}'));
              }
              String storeCity = citySnapshot.data ?? 'Unknown City';

              return SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        decoration: const BoxDecoration(color: Colors.white),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GridView.count(
                              shrinkWrap: true,
                              crossAxisCount: 3,
                              childAspectRatio: 1,
                              children: [
                                Center(
                                  child: SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: imageUrl != null
                                        ? ClipOval(
                                      child: FittedBox(
                                        fit: BoxFit.cover,
                                        child: ImageProduct(imageUrl: imageUrl),
                                      ),
                                    )
                                        : const Icon(
                                      Icons.account_circle,
                                      size: 80,
                                    ),
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      storeName,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on_sharp,
                                          size: 16,
                                        ),
                                        const SizedBox(
                                          width: 2,
                                        ),
                                        Text(storeCity),
                                      ],
                                    ),
                                  ],
                                ),
                                IconButton(
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            StoreEditProfilePage(storeID: storeID),
                                      ),
                                    );
                                    setState(() {
                                      _fetchData();
                                    });
                                  },
                                  icon: const Icon(Icons.settings),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: const BoxDecoration(color: Colors.white),
                        child: Padding(
                          padding: const EdgeInsets.all(25.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TransparentButton(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          StoreProductPage(storeID: storeID),
                                    ),
                                  );
                                },
                                msg: 'My Products',
                              ),
                              TransparentButton(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StoreTransactionPage(storeID: storeID),
                                    ),
                                  );
                                },
                                msg: 'Transactions',
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
