import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  final String uid;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final String role;
  final String address;
  final Timestamp timestamp;

  Users({
    required this.uid,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.address,
    required this.timestamp
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'address': address,
      'timestamp': timestamp
    };
  }
}