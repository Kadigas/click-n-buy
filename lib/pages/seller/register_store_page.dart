import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fp_ppb/components/big_button.dart';
import 'package:fp_ppb/pages/seller/store_profile_page.dart';
import 'package:fp_ppb/service/store_service.dart';
import 'package:fp_ppb/service/user_service.dart';

class RegisterStorePage extends StatefulWidget {
  const RegisterStorePage({super.key});

  @override
  State<RegisterStorePage> createState() => _RegisterStorePageState();
}

class _RegisterStorePageState extends State<RegisterStorePage> {
  late String email;
  final storeNameController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();

  late Future<DocumentSnapshot> _userDocument;

  @override
  void initState() {
    super.initState();
    String uid = FirebaseAuth.instance.currentUser!.uid;
    _userDocument =
        FirebaseFirestore.instance.collection('users').doc(uid).get();
    _userDocument.then((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        email = data['email'];
        addressController.text = data['address'];
        cityController.text = data['city'];
      }
    });
  }

  void registerStore() async {
    final StoreService storeService = StoreService();
    final UserService userService = UserService();
    String uid = FirebaseAuth.instance.currentUser!.uid;

    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      await storeService.registerStore(
        email,
        storeNameController.text,
        addressController.text,
        cityController.text,
      );
      await userService.updateHasStore(uid);
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context).pop();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const StoreProfilePage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      showErrorMessage(e.code);
    }
  }

  void showErrorMessage(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.red,
            title: Center(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register Store"),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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

          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Form(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: storeNameController,
                        decoration: InputDecoration(labelText: 'Store Name'),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: addressController,
                        decoration: InputDecoration(labelText: 'Address'),
                      ),
                      TextFormField(
                        controller: cityController,
                        decoration: InputDecoration(labelText: 'City'),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(height: 20),
                      BigButton(
                        onTap: () {
                          registerStore();
                        },
                        color: Colors.blueAccent,
                        msg: 'Save Changes',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
