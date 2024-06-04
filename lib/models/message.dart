import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String senderEmail;
  final String receiverId;
  final String message;
  final Timestamp timestamp;
  final String? type;
  final String? imageLink;
  final bool? isDelete;
  final bool? isEdit;

  Message({required this.message, required this.senderId, required this.senderEmail, required this.receiverId, required this.timestamp, this.type, this.imageLink, this.isDelete, this.isEdit});

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
      'type': type?? "message",
      'imageLink': imageLink?? "",
      'isDelete': isDelete?? false,
      'isEdit': isEdit?? false
    };
  }
}