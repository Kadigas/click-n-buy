import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  final String uid;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final bool hasStore;
  String? address;
  String? province;
  String? city;
  String? imageUrl;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  Users({
    required this.uid,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.hasStore,
    this.address,
    this.province,
    this.city,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Users.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Users(
      uid: data['uid'],
      email: data['email'],
      username: data['username'],
      firstName: data['firstName'],
      lastName: data['lastName'],
      hasStore: data['hasStore'],
      address: data['address'],
      province: data['province'],
      city: data['city'],
      imageUrl: data['imageUrl'],
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'hasStore': hasStore,
      'address': address ?? "",
      'province': province ?? "",
      'city': city ?? "",
      'imageUrl': imageUrl ?? "",
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}