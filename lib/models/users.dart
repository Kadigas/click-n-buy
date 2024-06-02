import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  final String uid;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final bool hasStore;
  final String address;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  Users({
    required this.uid,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.hasStore,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'hasStore': hasStore,
      'address': address,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}