import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:fp_ppb/enums/chat_types.dart';
import 'package:fp_ppb/models/message.dart';
import 'package:fp_ppb/service/auth_service.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _auth = AuthService();

  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _firestore.collection("users").snapshots().map((event) {
      return event.docs.map((doc) {
        final user = doc.data();

        return user;
      }).toList();
    });
  }

  Future sendMessage(String receiverId, message,
      {String? type, String? imageLink}) async {
    type ??= MessageType.text.value;
    imageLink ??= "";

    final currentUser = _auth.getCurrentUser();

    final String currentUserId = currentUser!.uid;
    final String? currentUserEmail = currentUser!.email;
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
        message: message,
        senderId: currentUserId,
        senderEmail: currentUserEmail!,
        receiverId: receiverId,
        timestamp: timestamp,
        type: type,
        imageLink: imageLink);
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection("messages")
        .add(newMessage.toMap());
  }

  Stream<QuerySnapshot> getMessages(String userId, otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatroomId = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatroomId)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  String getUserRoomId(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');
    return chatRoomId;
  }

  Future<void> editMessage(String userId, String otherUserId, String messageId,
      Map<Object, Object?> editedDataObj) async {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');
    try {
      await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .update(editedDataObj);
      if (kDebugMode) {
        print('Message edited $messageId successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error editing message: $e');
      }
    }
  }

  Future<void> deleteMessageInChatRoom(
      String userId, String otherUserId, String messageId) async {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');
    try {
      await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting message: $e');
      }
    }
  }

  Future<void> deleteMessage(String userId, String otherUserId) async {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatroomId = ids.join('_');

    await deleteDocumentWithSubcollections('chat_rooms', chatroomId);
  }

  Future<void> deleteDocumentWithSubcollections(
      String collectionPath, String documentId) async {
    // Reference to the document
    var documentReference =
        FirebaseFirestore.instance.collection(collectionPath).doc(documentId);

    // List of known subcollections (you need to specify these manually)
    List<String> subcollections = [
      'messages',
      'attachments'
    ]; // Example subcollections

    // Delete all subcollections
    for (var subcollection in subcollections) {
      await deleteCollection('$collectionPath/$documentId/$subcollection',
          batchSize: 10);
    }

    // Delete the document itself
    await documentReference.delete();
  }

  Future<void> deleteCollection(String collectionPath,
      {int batchSize = 10}) async {
    var collectionReference =
        FirebaseFirestore.instance.collection(collectionPath);

    var querySnapshot;
    do {
      querySnapshot = await collectionReference.limit(batchSize).get();

      var batch = FirebaseFirestore.instance.batch();
      for (var document in querySnapshot.docs) {
        batch.delete(document.reference);
      }
      await batch.commit();
    } while (querySnapshot.size >= batchSize);
  }
}
