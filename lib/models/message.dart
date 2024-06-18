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
  final String? storeId;
  final bool? isSeller;
  final String userName;
  final String userId;

  Message({
    required this.message,
    required this.senderId,
    required this.senderEmail,
    required this.receiverId,
    required this.timestamp,
    this.type,
    this.imageLink,
    this.isDelete,
    this.isEdit,
    this.storeId,
    this.isSeller,
    required this.userName,
    required this.userId,
  });

  // Factory constructor to create a Message instance from Firestore document snapshot
  factory Message.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Message(
      message: data['message'],
      senderId: data['senderId'],
      senderEmail: data['senderEmail'],
      receiverId: data['receiverId'],
      timestamp: data['timestamp'],
      type: data['type'],
      imageLink: data['imageLink'],
      isDelete: data['isDelete'],
      isEdit: data['isEdit'],
      storeId: data['storeId'],
      isSeller: data['isSeller'],
      userName: data['userName'],
      userId: data['userId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'storeId': storeId ?? '',
      'senderId': senderId,
      'senderEmail': senderEmail,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
      'type': type ?? "message",
      'imageLink': imageLink ?? "",
      'isDelete': isDelete ?? false,
      'isEdit': isEdit ?? false,
      'isSeller': isSeller ?? false,
      'userName': userName,
      'userId': userId,
    };
  }
}