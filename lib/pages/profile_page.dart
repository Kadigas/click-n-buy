import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fp_ppb/components/small_button.dart';
import 'package:fp_ppb/pages/seller/register_store_page.dart';
import 'package:fp_ppb/pages/seller/store_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<DocumentSnapshot> _userDocument;

  @override
  void initState() {
    super.initState();
    String uid = FirebaseAuth.instance.currentUser!.uid;
    _userDocument =
        FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _userDocument,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User not found'));
          }

          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          String username = data['username'];
          String firstName = data['firstName'];
          String lastName = data['lastName'];
          bool hasStore = data['hasStore'];

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
                                    username,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        firstName,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        lastName,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  SmallButton(
                                      onTap: () {
                                        if (!hasStore) {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text('Don\'t have a store yet!'),
                                                content: const Text('Do you want to make a store account?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => const RegisterStorePage(),
                                                        ),
                                                      );
                                                    },
                                                    child: const Text('Yes'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const StoreProfilePage(),
                                            ),
                                          );
                                        }
                                      },
                                      msg: 'Store account',
                                      color: Colors.black),
                                ],
                              ),
                              const SizedBox(
                                width: 25,
                              ),
                              IconButton(
                                  onPressed: () {}, icon: const Icon(Icons.settings))
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
