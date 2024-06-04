import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:fp_ppb/enums/chat_types.dart';

class ChatBox extends StatelessWidget {
  final String? text;
  final bool isMe;
  final DateTime timestamp;
  final String? imageUrl;
  final MessageType messageType;

  const ChatBox({
    super.key,
    this.text,
    required this.isMe,
    required this.timestamp,
    this.imageUrl,
    required this.messageType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isMe)
              const CircleAvatar(
                backgroundColor: Colors.grey,
                child: Text("A"), // Placeholder avatar
              ),
            const SizedBox(width: 8),
            Flexible(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                decoration: BoxDecoration(
                  color: isMe ? Colors.blue : Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (messageType == MessageType.image && imageUrl != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Image.network(imageUrl!),
                      ),
                    if (text != null && text!.isNotEmpty)
                      Text(
                        text!,
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black87,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (isMe)
              const CircleAvatar(
                backgroundColor: Colors.grey,
                child: Text("Me"), // Placeholder avatar for the current user
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            "${timestamp.hour}:${timestamp.minute}",
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        )
      ],
    );
  }
}