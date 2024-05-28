import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future sendMessage(String receiverId, message) async {
    final currentUser = _auth.getCurrentUser();

    final String currentUserId = currentUser!.uid;
    final String? currentUserEmail = currentUser!.email;
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
        message: message,
        senderId: currentUserId,
        senderEmail: currentUserEmail!,
        receiverId: receiverId,
        timestamp: timestamp);
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection("messages")
        .add(newMessage.toMap());
  }
}
