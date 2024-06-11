import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fp_ppb/pages/chat/chat_page.dart';
import 'package:fp_ppb/service/store_service.dart';

import '../../service/auth_service.dart';
import '../../service/chat_service.dart';

class ListUserPage extends StatelessWidget {
  ListUserPage({super.key});

  final ChatService chatService = ChatService();
  final AuthService authService = AuthService();
  final StoreService storeService = StoreService();
  bool isSeller = false;

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
              List<Map<String, dynamic>> users = snapshot.data!;
              if (kDebugMode) {
                print(users);
              }

              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  String storeId = users[index]['storeId'];
                  String message = users[index]['message'];
                  String userId = authService.getCurrentUser()!.uid;
                  String otherUserId = users[index]['senderId'] != userId? users[index]['senderId']: users[index]['receiverId'];

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
                          title: Text('No data available'),
                        );
                      } else {
                        String storeName = storeNameSnapshot.data!;
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
                                  showName: storeName,
                                  userId: userId,
                                  otherUserId: otherUserId,
                                  storeId: storeId,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            child: ListTile(
                              title: Text(
                                storeName,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              subtitle: Text(message),
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
