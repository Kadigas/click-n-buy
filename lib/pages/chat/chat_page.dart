import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fp_ppb/enums/image_cloud_endpoint.dart';
import 'package:image_picker/image_picker.dart';
import '../../components/chat/chat_box.dart';
import '../../service/auth_service.dart';
import '../../service/chat_service.dart';
import '../../service/image_cloud_service.dart';
import '../../enums/chat_types.dart';

class ChatPage extends StatefulWidget {
  final String userId;
  final String showName;
  final String otherUserId;
  final bool? isSeller;
  final String storeId;

  const ChatPage(
      {super.key,
      required this.userId,
      required this.showName,
      required this.otherUserId,
      this.isSeller,
      required this.storeId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatService chatService = ChatService();
  final AuthService authService = AuthService();
  final ImageCloudService imageUploadService = ImageCloudService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController =
      ScrollController(); // Initialize ScrollController

  bool isEditMode = false;
  String editedMessageId = "";

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose(); // Dispose the ScrollController
    super.dispose();
  }

  void setIsEditMode(String messageText, String messageId) {
    _messageController.text = messageText;
    setState(() {
      editedMessageId = messageId;
      isEditMode = true;
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void sendMessage({String? text, MessageType? type, String? imagePath}) async {
    bool isSeller = widget.isSeller ?? false;
    String storeId = widget.storeId ?? "";
    if (text?.isNotEmpty == true) {
      await chatService.sendMessage(
        widget.otherUserId,
        text,
        isSeller,
        storeId,
        type: MessageType.text.value,
      );
    } else if (type == MessageType.image && imagePath != null) {
      // upload the image first to image upload service
      // if success then will return filename, the filename will use in showing image
      await chatService.sendMessage(
        widget.otherUserId,
        "",
        isSeller,
        storeId,
        type: MessageType.image.value,
        imageLink: imagePath,
      );
    }
    _messageController.clear();
    _scrollToBottom();
  }

  Future<XFile?> pickImage() async {
    return await imageUploadService.pickImageFromGallery();
  }

  Future editMessage(
      String messageId, Map<Object, Object?> editedDataObj) async {
    await chatService.editMessage(
        widget.userId, widget.otherUserId, messageId, editedDataObj);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.showName),
        centerTitle: true,
        actions: [
          const Icon(Icons.info),
          IconButton(
            onPressed: () async {
              await chatService.deleteMessage(
                  widget.userId, widget.otherUserId);
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
                stream:
                    chatService.getMessages(widget.userId, widget.otherUserId),
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
                    Map<String, dynamic> data =
                        doc.data() as Map<String, dynamic>;
                    return ChatBox(
                        text: data['message'],
                        isMe: data['senderId'] ==
                            authService.getCurrentUser()!.uid,
                        timestamp: data['timestamp'].toDate(),
                        imageUrl: data['imageLink'],
                        messageType: data['type'] == 'image'
                            ? MessageType.image
                            : MessageType.text,
                        idMessage: doc.id,
                        editMessage: editMessage,
                        isDelete: data['isDelete'],
                        isEdit: data['isEdit'],
                        setIsEditMode: setIsEditMode);
                  }).toList();
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => _scrollToBottom());
                  return ListView(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
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
            icon: const Icon(Icons.photo),
            onPressed: () async {
              XFile? image = await pickImage();
              String? filename = await imageUploadService.uploadImage(image!);
              String imageUrl = imageUploadService.getEndpoint(
                  ImageUploadEndpoint.getImageByFilename,
                  arg: filename);
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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.orangeAccent,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () async {
                if (!isEditMode) {
                  sendMessage(text: _messageController.text);
                } else {
                  await editMessage(editedMessageId,
                      {'message': _messageController.text, 'isEdit': true});
                  _messageController.clear();
                  setState(() {
                    isEditMode = false;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
