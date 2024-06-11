import 'package:cloud_firestore/cloud_firestore.dart';

class MessageTile {
  final String userName;
  final String storeName;
  final String message;
  final Timestamp timestamp;
  final String type;
  final bool isDelete;
  final int? countNotRead;

  MessageTile({required this.userName, required this.storeName, required this.message, required this.timestamp, required this.type, required this.isDelete, this.countNotRead});

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'storeName': storeName,
      'message': message,
      'timestamp': timestamp,
      'type': type,
      'isDelete': isDelete,
      'countNotRead': countNotRead?? 0
    };
  }
}