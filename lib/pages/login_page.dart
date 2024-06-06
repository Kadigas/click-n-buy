import 'package:firebase_auth/firebase_auth.dart';
import 'package:fp_ppb/components/big_button.dart';
import 'package:fp_ppb/components/square_tile.dart';
import 'package:flutter/material.dart';
import 'package:fp_ppb/components/my_textfield.dart';
import 'package:fp_ppb/service/auth_service.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;

  const LoginPage({required this.onTap, super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void _loadingState() {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  void signUserIn() async {
    final authService = AuthService();
    _loadingState();

    try {
      await authService.signInWithEmailPassword(
          emailController.text, passwordController.text);
      Navigator.of(context, rootNavigator: true).pop();
    } catch (e) {
      Navigator.pop(context);
      showErrorMessage(e.toString().replaceFirst('Exception: ', 'Error: '));
    }
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.red,
          title: Center(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                Image.network(
                  "https://static.wikia.nocookie.net/kamenrider/images/a/a5/Hiden_Intelligence_Logo.png/revision/latest?cb=20221105005206",
                  height: 50,
                ),
                const SizedBox(height: 35),
                const Text(
                  'Welcome Back! you\'ve been missed!',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 35),
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                BigButton(
                  onTap: signUserIn,
                  msg: 'Sign In',
                  color: Colors.blueAccent,
                ),
                const SizedBox(height: 35),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 35),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SquareTile(
                        imgUrl:
                            "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/480px-Google_%22G%22_logo.svg.png"),
                    SizedBox(width: 25),
                    SquareTile(
                        imgUrl:
                            "https://freepnglogo.com/images/all_img/1713419057Facebook_PNG.png"),
                  ],
                ),
                const SizedBox(height: 35),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Not a member?'),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Register now.',
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
