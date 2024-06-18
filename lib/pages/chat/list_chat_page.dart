import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fp_ppb/pages/chat/chat_page.dart';
import 'package:fp_ppb/service/store_service.dart';

import '../../service/auth_service.dart';
import '../../service/chat_service.dart';

class ListUserPage extends StatelessWidget {
  final bool isSeller;

  ListUserPage({super.key, required this.isSeller});

  final ChatService chatService = ChatService();
  final AuthService authService = AuthService();
  final StoreService storeService = StoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
        centerTitle: true,
        // action is multiple action on the right side
        backgroundColor: Colors.orangeAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: chatService.getListChatStream(
              isSeller, authService.getCurrentUser()!.uid),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Map<String, dynamic>> messages = snapshot.data!;
              if (messages.isEmpty) {
                return const Center(
                  child: Text("No chat available"),
                );
              }

              return ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  String storeId = messages[index]['storeId'];
                  String message = messages[index]['message'];
                  String userId = authService.getCurrentUser()!.uid;
                  String otherUserId = messages[index]['senderId'] != userId
                      ? messages[index]['senderId']
                      : messages[index]['receiverId'];
                  String clientName = messages[index]['userName'];
                  String messageType = messages[index]['type'];

                  return FutureBuilder<String>(
                    future: storeService.getStoreName(storeId),
                    builder: (context, storeNameSnapshot) {
                      if (storeNameSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const ListTile(
                          title: Text('Loading...'),
                        );
                      } else if (storeNameSnapshot.hasError) {
                        return ListTile(
                          title: Text('Error: ${storeNameSnapshot.error}'),
                        );
                      } else if (!storeNameSnapshot.hasData) {
                        return const ListTile(
                          title: Text(
                            'No data available',
                            style: TextStyle(color: Colors.black),
                          ),
                        );
                      } else {
                        String storeName = storeNameSnapshot.data!;
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
                                  showName: isSeller ? clientName : storeName,
                                  userId: userId,
                                  otherUserId: otherUserId,
                                  storeId: storeId,
                                  isSeller: isSeller,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            child: ListTile(
                              title: Text(
                                isSeller ? clientName : storeName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700),
                              ),
                              subtitle: Text(messageType == 'image'
                                  ? "🖼 photo"
                                  : message),
                              // Customize this as per your user model
                              leading: const Icon(Icons.message),
                            ),
                          ),
                        );
                      }
                    },
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
    );
  }
}
