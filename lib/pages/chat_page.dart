import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fp_ppb/components/chat_box.dart';
import 'package:fp_ppb/service/auth_service.dart';
import 'package:fp_ppb/service/chat_service.dart';

class ChatPage extends StatefulWidget {
  ChatPage({super.key});

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
      await chatService.sendMessage(receiverId, _messageController.text);
      _messageController.text = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("seller/customer name"),
        centerTitle: true,
        // action is multiple action on the right side
        actions: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.info),
          ),
          IconButton(onPressed: () async {}, icon: const Icon(Icons.delete))
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
            Text("current user: ${authService.getCurrentUser()!.email}"),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("receiver name: $receiverName"),
                Text("receiver id: $receiverId"),
                TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                IconButton(onPressed: () {
                  sendMessage();
                }, icon: Icon(Icons.send))
              ],
            ),
            Expanded(
              child: StreamBuilder(
                stream: chatService.getUserStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List users = snapshot.data!;
                    if (kDebugMode) {
                      print(users);
                    }
                    // Return a widget displaying the users or whatever UI you need
                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              receiverName = users[index]['email'];
                              receiverId = users[index]['uid'];
                            });
                          },
                          child: ListTile(
                            title: Text(users[index]['email']
                                .toString()), // Customize this as per your user model
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return ChatBox(
                      text: messages[index]['message'],
                      isMe: messages[index]["isMe"],
                      timestamp: messages[index]['timestamp']);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
