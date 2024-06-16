import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final Function()? onTap;
  final String msg;
  final Color color;

  const MyButton({
    super.key,
    required this.onTap,
    required this.msg,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8)
        ),
        child: Center(
          child: Text(
            msg,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
