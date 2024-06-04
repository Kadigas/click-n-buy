import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fp_ppb/enums/image_upload_endpoint.dart';
import 'package:image_picker/image_picker.dart';
import '../../components/chat/chat_box.dart';
import '../../service/auth_service.dart';
import '../../service/chat_service.dart';
import '../../service/image_upload_service.dart';
import '../../enums/chat_types.dart';

class ChatPage extends StatefulWidget {
  final String userId;
  final String userEmail;
  final String otherUserId;

  const ChatPage({
    super.key,
    required this.userId,
    required this.userEmail,
    required this.otherUserId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatService chatService = ChatService();
  final AuthService authService = AuthService();
  final ImageUploadService imageUploadService = ImageUploadService();
  final TextEditingController _messageController = TextEditingController();

  void sendMessage({String? text, MessageType? type, String? imagePath}) async {
    if (text?.isNotEmpty == true) {
      await chatService.sendMessage(
        widget.otherUserId,
        text,
        type: MessageType.text.value,
      );
    } else if (type == MessageType.image && imagePath != null) {
      // upload the image first to image upload service
      // if success then will return filename, the filename will use in showing image
      await chatService.sendMessage(
        widget.otherUserId,
        "",
        type: MessageType.image.value,
        imageLink: imagePath,
      );
    }
    _messageController.clear();
  }

  Future<XFile?> pickImage() async {
    return await imageUploadService.pickImageFromGallery();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userEmail),
        centerTitle: true,
        actions: [
          const Icon(Icons.info),
          IconButton(
            onPressed: () async {
              await chatService.deleteMessage(widget.userId, widget.otherUserId);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.delete),
          )
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
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: chatService.getMessages(widget.userId, widget.otherUserId),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No messages yet"));
                  }
                  var messages = snapshot.data!.docs.map((doc) {
                    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                    return ChatBox(
                      text: data['message'],
                      isMe: data['senderId'] == authService.getCurrentUser()!.uid,
                      timestamp: data['timestamp'].toDate(),
                      imageUrl: data['imageLink'],
                      messageType: data['type'] == 'image' ? MessageType.image : MessageType.text,
                    );
                  }).toList();
                  return ListView(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    children: messages,
                  );
                },
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(15.0),
      color: Colors.grey[200],
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.photo),
            onPressed: () async {
              XFile? image = await pickImage();
              String? filename = await imageUploadService.uploadImage(image!);
              String imageUrl = imageUploadService.getEndpoint(ImageUploadEndpoint.getImageByFilename, arg: filename);
              if (image != null) {
                sendMessage(type: MessageType.image, imagePath: imageUrl);
              }
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Message',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onSubmitted: (_) => sendMessage(text: _messageController.text),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.orangeAccent,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () => sendMessage(text: _messageController.text),
            ),
          ),
        ],
      ),
    );
  }
}