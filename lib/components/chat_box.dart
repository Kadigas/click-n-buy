import 'package:flutter/material.dart';

class ChatBox extends StatelessWidget {
  final String text;
  final bool isMe;
  final DateTime timestamp;

  const ChatBox({super.key, required this.text, required this.isMe, required this.timestamp});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(
            bottom: 10, top: 10, right: isMe ? 50 : 10, left: isMe ? 10 : 50),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          text,
          textAlign: TextAlign.left,
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
