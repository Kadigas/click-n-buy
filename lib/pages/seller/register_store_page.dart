import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fp_ppb/components/big_button.dart';
import 'package:fp_ppb/components/custom_dropdown.dart';
import 'package:fp_ppb/pages/seller/store_profile_page.dart';
import 'package:fp_ppb/service/location_cloud_service.dart';
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
  String? selectedCity;
  String? selectedProvince;

  late Future<DocumentSnapshot> _userDocument;

  List<Map<String, dynamic>> provinces = [];
  List<Map<String, dynamic>> cities = [];

  final locationCloudService = LocationCloudService();

  @override
  void initState() {
    super.initState();
    String uid = FirebaseAuth.instance.currentUser!.uid;
    _userDocument =
        FirebaseFirestore.instance.collection('users').doc(uid).get();
    _userDocument.then((snapshot) async {
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        email = data['email'];
        addressController.text = data['address'];
        selectedCity = data['city'];
        selectedProvince = data['province'];

        // Fetch and set cities for the initially saved province
        if (selectedProvince != null) {
          List<Map<String, dynamic>> fetchedCities =
              await locationCloudService.getCities(selectedProvince!);
          setState(() {
            cities = fetchedCities;
          });
        }
      }
    });

    locationCloudService.getProvinces().then((provinces) {
      setState(() {
        this.provinces = provinces;
      });
    });
  }

  void registerStore() async {
    if (!validateFields()) {
      return;
    }

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
      await storeService.registerStore(email, storeNameController.text,
          addressController.text, selectedCity!, selectedProvince!);
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

  bool validateFields() {
    if(addressController.text == null) {
      showErrorMessage("Address cannot be empty!");
      return false;
    }
    if (selectedProvince == null) {
      showErrorMessage("Province cannot be empty!");
      return false;
    }
    if (selectedCity == null) {
      showErrorMessage("City cannot be empty!");
      return false;
    }
    return true;
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
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: email,
                        readOnly: true,
                        style: const TextStyle(color: Colors.grey),
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.grey),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: storeNameController,
                        decoration:
                            const InputDecoration(labelText: 'Store Name'),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: addressController,
                        decoration: const InputDecoration(labelText: 'Address'),
                      ),
                      const SizedBox(height: 10),
                      buildDropdownButtonFormField(
                        selectedValue: selectedProvince,
                        label: 'Province',
                        items: provinces,
                        onChanged: (value) async {
                          setState(() {
                            selectedProvince = value;
                            selectedCity =
                                null;
                            cities = [];
                          });
                          if (value != null) {
                            List<Map<String, dynamic>> fetchedCities =
                                await locationCloudService.getCities(value);
                            setState(() {
                              cities = fetchedCities;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      buildDropdownButtonFormField(
                        selectedValue: selectedCity,
                        label: 'City',
                        items: cities,
                        onChanged: (value) {
                          setState(() {
                            selectedCity = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
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

  @override
  void dispose() {
    storeNameController.dispose();
    addressController.dispose();
    super.dispose();
  }
}
