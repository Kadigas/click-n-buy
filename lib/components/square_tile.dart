import 'package:flutter/material.dart';

class SquareTile extends StatelessWidget {
  final String imgUrl;
  const SquareTile({
    super.key,
    required this.imgUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[100]
      ),
      child: Image.network(
        imgUrl,
        height: 42,
      ),
    );
  }
}
