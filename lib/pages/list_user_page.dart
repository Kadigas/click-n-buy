import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fp_ppb/pages/chat/chat_page.dart';

import '../service/auth_service.dart';
import '../service/chat_service.dart';

class ListUserPage extends StatelessWidget {
  ListUserPage({super.key});

  final ChatService chatService = ChatService();
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("List User"),
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
                      String userId = authService.getCurrentUser()!.uid;
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChatPage(
                                    userEmail: users[index]['email'].toString(),
                                    userId: userId,
                                    otherUserId: users[index]['uid'].toString(),
                                  )));
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
    );
  }
}
