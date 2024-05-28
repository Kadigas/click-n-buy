import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fp_ppb/components/chat_box.dart';
import 'package:fp_ppb/service/auth_service.dart';
import 'package:fp_ppb/service/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String userId;
  final String userEmail;
  final String otherUserId;

  const ChatPage({super.key, required this.userId, required this.userEmail, required this.otherUserId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatService chatService = ChatService();

  final AuthService authService = AuthService();

  final List<Map<String, dynamic>> messages = [
    {
      'message': 'Hello!',
      'isMe': true,
      'timestamp': DateTime.now().subtract(Duration(minutes: 1))
    },
    {
      'message': 'Hi there!',
      'isMe': false,
      'timestamp': DateTime.now().subtract(Duration(minutes: 2))
    },
    {
      'message': 'How are you?',
      'isMe': true,
      'timestamp': DateTime.now().subtract(Duration(minutes: 3))
    },
    {
      'message': 'I\'m good, thanks! And you?',
      'isMe': false,
      'timestamp': DateTime.now().subtract(Duration(minutes: 4))
    },
  ];

  String receiverName = "";
  String receiverId = "";
  final TextEditingController _messageController = TextEditingController();

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await chatService.sendMessage(widget.otherUserId, _messageController.text);
      _messageController.text = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userEmail),
        centerTitle: true,
        // action is multiple action on the right side
        actions: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.info),
          ),
          IconButton(onPressed: () async {
            await chatService.deleteMessage(widget.userId, widget.otherUserId);
            Navigator.pop(context);
          }, icon: const Icon(Icons.delete))
        ],
        backgroundColor: Colors.orangeAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("current user: ${widget.userId}"),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("receiver name: $receiverName"),
                Text("receiver id: ${widget.otherUserId}"),
                TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      sendMessage();
                    },
                    icon: const Icon(Icons.send))
              ],
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: chatService.getMessages(
                    widget.userId, widget.otherUserId),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No messages yet"));
                  }

                  var messages = snapshot.data!.docs.map((doc) {
                    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

                    return ChatBox(
                      text: data['message'],
                      isMe: data['senderId'] == authService.getCurrentUser()!.uid,
                      timestamp: data['timestamp'].toDate(),
                    );
                  }).toList();

                  return ListView(
                    children: messages,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
