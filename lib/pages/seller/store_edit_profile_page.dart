import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fp_ppb/components/big_button.dart';
import 'package:fp_ppb/components/custom_dropdown.dart';
import 'package:fp_ppb/components/image_product.dart';
import 'package:fp_ppb/enums/image_cloud_endpoint.dart';
import 'package:fp_ppb/service/image_cloud_service.dart';
import 'package:fp_ppb/service/store_service.dart';
import 'package:fp_ppb/service/location_cloud_service.dart'; // Import the location service
import 'package:image_picker/image_picker.dart';

class StoreEditProfilePage extends StatefulWidget {
  final String storeID;

  const StoreEditProfilePage({
    super.key,
    required this.storeID,
  });

  @override
  State<StoreEditProfilePage> createState() => _StoreEditProfilePageState();
}

class _StoreEditProfilePageState extends State<StoreEditProfilePage> {
  late Future<DocumentSnapshot> _document;
  final storeNameController = TextEditingController();
  final addressController = TextEditingController();
  String? imageUrl;
  final ImageCloudService imageUploadService = ImageCloudService();
  final locationCloudService = LocationCloudService(); // Initialize the location service

  List<Map<String, dynamic>> provinces = [];
  List<Map<String, dynamic>> cities = [];
  String? selectedProvince;
  String? selectedCity;

  void _loadingState() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  void editProfile(String? imageUrl) async {
    if (!validateFields()) {
      return;
    }

    final storeService = StoreService();
    _loadingState();

    try {
      await storeService.updateProfile(
        widget.storeID,
        storeNameController.text,
        addressController.text,
        selectedCity!,
        selectedProvince!,
        imageUrl,
      );
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      showErrorMessage(e.code);
    }
  }

  bool validateFields() {
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

  Future<XFile?> pickImage() async {
    return await imageUploadService.pickImageFromGallery();
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
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _document = FirebaseFirestore.instance.collection('stores').doc(widget.storeID).get();
    _document.then((snapshot) async {
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        storeNameController.text = data['storeName'];
        addressController.text = data['address'];
        selectedCity = data['city'];
        selectedProvince = data['province'];
        imageUrl = data['imageUrl'];

        if (selectedProvince != null) {
          List<Map<String, dynamic>> fetchedCities = await locationCloudService.getCities(selectedProvince!);
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

  @override
  void dispose() {
    storeNameController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black,
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
      backgroundColor: Colors.grey[200],
      body: FutureBuilder<DocumentSnapshot>(
        future: _document,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Document not found'));
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                child: Column(
                  children: [
                    if (imageUrl != null)
                      Column(
                        children: [
                          Stack(
                            children: [
                              Center(
                                child: Container(
                                  width: 220,
                                  height: 220,
                                  child: ClipOval(
                                    child: FittedBox(
                                      fit: BoxFit.cover,
                                      child: ImageProduct(imageUrl: imageUrl),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: -10,
                                right: 55,
                                child: IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    setState(() {
                                      imageUrl = null;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                        ],
                      )
                    else
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.add_photo_alternate,
                              size: 180,
                            ),
                            onPressed: () async {
                              XFile? image = await pickImage();
                              if (image != null) {
                                _loadingState();
                                String? filename = await imageUploadService.uploadImage(image!);
                                Navigator.of(context, rootNavigator: true).pop();
                                setState(() {
                                  imageUrl = imageUploadService.getEndpoint(
                                    ImageUploadEndpoint.getImageByFilename,
                                    arg: filename,
                                  );
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    TextFormField(
                      controller: storeNameController,
                      decoration: const InputDecoration(labelText: 'Store Name'),
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
                          selectedCity = null; // Reset city when province changes
                          cities = []; // Clear city list
                        });
                        if (value != null) {
                          List<Map<String, dynamic>> fetchedCities = await locationCloudService.getCities(value);
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
                        editProfile(imageUrl);
                      },
                      color: Colors.blueAccent,
                      msg: 'Save Changes',
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
