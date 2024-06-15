import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fp_ppb/enums/image_cloud_endpoint.dart';
import 'package:image_picker/image_picker.dart';

import '../../components/chat/chat_box.dart';
import '../../components/chat/progress_dialog.dart';
import '../../models/users.dart';
import '../../service/auth_service.dart';
import '../../service/chat_service.dart';
import '../../service/image_cloud_service.dart';
import '../../enums/chat_types.dart';

class ChatPage extends StatefulWidget {
  final String userId;
  final String showName;
  final String otherUserId;
  final bool isSeller;
  final String storeId;

  const ChatPage({
    super.key,
    required this.userId,
    required this.showName,
    required this.otherUserId,
    required this.isSeller,
    required this.storeId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatService chatService = ChatService();
  final AuthService authService = AuthService();
  final ImageCloudService imageUploadService = ImageCloudService();

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool isEditMode = false;
  String editedMessageId = "";
  late Users user;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    Users fetchUser = await authService.getDetailUser(widget.userId) as Users;
    setState(() {
      user = fetchUser;
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
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

  Future<void> showProgressDialog(BuildContext context, String message) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ProgressDialog(message: message);
      },
    );
  }

  void dismissProgressDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop(); // dismiss the progress dialog
  }

  void sendMessage(String userName, String userId, {String? text, MessageType? type, String? imagePath}) async {
    bool isSeller = widget.isSeller ?? false;
    String storeId = widget.storeId;
    if (text?.isNotEmpty == true) {
      await chatService.sendMessage(
        widget.otherUserId,
        text!,
        isSeller,
        storeId,
        userName,
        userId,
        type: MessageType.text.value,
      );
    } else if (type == MessageType.image && imagePath != null) {
      await chatService.sendMessage(
        widget.otherUserId,
        "",
        isSeller,
        storeId,
        userName,
        userId,
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

  Future<void> editMessage(String messageId, Map<Object, Object?> editedDataObj) async {
    await chatService.editMessage(
      widget.userId,
      widget.otherUserId,
      messageId,
      editedDataObj,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.showName),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await chatService.deleteMessage(widget.userId, widget.otherUserId, widget.isSeller);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.delete),
          ),
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
                      idMessage: doc.id,
                      editMessage: editMessage,
                      isDelete: data['isDelete'],
                      isEdit: data['isEdit'],
                      setIsEditMode: setIsEditMode,
                    );
                  }).toList();
                  WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                  return ListView(
                    controller: _scrollController,
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
            icon: const Icon(Icons.camera_alt),
            onPressed: () async {
              try {
                XFile? image = await imageUploadService.pickImageFromCamera();
                if (image != null) {
                  await showProgressDialog(context, 'Uploading...');
                  String? filename = await imageUploadService.uploadImage(image);
                  String imageUrl = imageUploadService.getEndpoint(ImageUploadEndpoint.getImageByFilename, arg: filename);
                  sendMessage(user.username, user.uid, type: MessageType.image, imagePath: imageUrl);
                  dismissProgressDialog(context);
                }
              } catch (e) {
                dismissProgressDialog(context); // Handle error appropriately
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to upload image')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.photo),
            onPressed: () async {
              try {
                XFile? image = await pickImage();
                if (image != null) {
                  await showProgressDialog(context, 'Uploading...');
                  String? filename = await imageUploadService.uploadImage(image);
                  String imageUrl = imageUploadService.getEndpoint(ImageUploadEndpoint.getImageByFilename, arg: filename);
                  sendMessage(user.username, user.uid, type: MessageType.image, imagePath: imageUrl);
                  dismissProgressDialog(context);
                }
              } catch (e) {
                dismissProgressDialog(context); // Handle error appropriately
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to upload image')),
                );
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
                  sendMessage(user.username, user.uid, text: _messageController.text);
                } else {
                  await editMessage(editedMessageId, {'message': _messageController.text, 'isEdit': true});
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