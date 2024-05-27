import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fp_ppb/components/chat_box.dart';

class ChatPage extends StatelessWidget {
  ChatPage({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("seller/customer name"),
        centerTitle: true,
        // action is multiple action on the right side
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.info),
          ),
        ],
        backgroundColor: Colors.orangeAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
        ),
      ),
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return ChatBox(
                      text: messages[index]['message'],
                      isMe: messages[index]["isMe"],
                      timestamp: messages[index]['timestamp']);
                }),
          ),
        ],
      )),
    );
  }
}
