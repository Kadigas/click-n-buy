import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fp_ppb/components/big_button.dart';
import 'package:fp_ppb/components/image_product.dart';
import 'package:fp_ppb/enums/image_cloud_endpoint.dart';
import 'package:fp_ppb/service/image_cloud_service.dart';
import 'package:fp_ppb/service/user_service.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  final String uid;

  const EditProfilePage({
    super.key,
    required this.uid,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late Future<DocumentSnapshot> _document;
  final usernameController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  String? imageUrl;
  final ImageCloudService imageUploadService = ImageCloudService();

  void _loadingState() {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  void editProfile(String? imageUrl) async {
    final userService = UserService();
    _loadingState();

    try {
      await userService.updateProfile(
        widget.uid,
        usernameController.text,
        firstNameController.text,
        lastNameController.text,
        addressController.text,
        cityController.text,
        imageUrl,
      );
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      showErrorMessage(e.code);
    }
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
          );
        });
  }

  @override
  void initState() {
    super.initState();
    _document =
        FirebaseFirestore.instance.collection('users').doc(widget.uid).get();
    _document.then((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        usernameController.text = data['username'];
        firstNameController.text = data['firstName'];
        lastNameController.text = data['lastName'];
        addressController.text = data['address'];
        cityController.text = data['city'];
        imageUrl = data['imageUrl'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        const Text("Edit Profile", style: TextStyle(color: Colors.white)),
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
                    imageUrl != null
                        ? Column(
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
                                  setState(
                                        () {
                                      imageUrl = null;
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                      ],
                    )
                        : Column(
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
                              String? filename = await imageUploadService
                                  .uploadImage(image!);
                              Navigator.of(context, rootNavigator: true)
                                  .pop();
                              setState(
                                    () {
                                  imageUrl =
                                      imageUploadService.getEndpoint(
                                          ImageUploadEndpoint
                                              .getImageByFilename,
                                          arg: filename);
                                },
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    TextFormField(
                      controller: usernameController,
                      decoration: const InputDecoration(labelText: 'Username'),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: firstNameController,
                      decoration:
                      const InputDecoration(labelText: 'First Name'),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: lastNameController,
                      decoration: const InputDecoration(labelText: 'Last Name'),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: addressController,
                      decoration: const InputDecoration(labelText: 'Address'),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: cityController,
                      decoration: const InputDecoration(labelText: 'City'),
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

  @override
  void dispose() {
    usernameController.dispose();
    firstNameController.dispose();
    super.dispose();
  }
}
