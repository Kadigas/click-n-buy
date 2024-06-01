import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black26),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            fillColor: Colors.grey.shade100,
            filled: true,
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey[500]
            )
          ),
        )
    );
  }
}
