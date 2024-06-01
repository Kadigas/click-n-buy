import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fp_ppb/components/my_textfield.dart';
import 'package:fp_ppb/pages/chat_page.dart';
import 'package:fp_ppb/pages/list_user_page.dart';
import 'package:fp_ppb/service/auth_service.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;

  final itemController = TextEditingController();

  void signUserOut() {
    final authService = AuthService();
    authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: MyTextField(
                          controller: itemController,
                          hintText: "Search...",
                          obscureText: false),
                    ),
                    // const Icon(Icons.search),
                    Row(
                      children: [
                        IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.shopping_cart)),
                        IconButton(
                          onPressed: signUserOut,
                          icon: const Icon(Icons.logout),
                        ),
                      ],
                    ),
                    IconButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => ListUserPage()));
                        },
                        icon: const Icon(Icons.chat)),

                  ],
                ),
                SizedBox(height: 25),
                Text(
                  "Elektronik",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Card(
                      color: Colors.white,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        width: 160,
                        height: 180,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Elektronik 1',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            Icon(
                              Icons.keyboard,
                              size: 100,
                            ),
                            Text(
                              "Rp1.000.000",
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      color: Colors.white,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        width: 160,
                        height: 180,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Elektronik 1',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            Icon(
                              Icons.keyboard,
                              size: 100,
                            ),
                            Text(
                              "Rp1.000.000",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
