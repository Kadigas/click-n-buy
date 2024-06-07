import 'package:flutter/material.dart';

class QuantityEditor extends StatefulWidget {
  final int initialQuantity;
  final Function(int) onQuantityChanged;

  const QuantityEditor({
    super.key,
    required this.initialQuantity,
    required this.onQuantityChanged,
  });

  @override
  State<QuantityEditor> createState() => _QuantityEditorState();
}

class _QuantityEditorState extends State<QuantityEditor> {
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity;
  }

  void _increaseQuantity() {
    setState(() {
      _quantity++;
    });
    widget.onQuantityChanged(_quantity);
  }

  void _decreaseQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
      widget.onQuantityChanged(_quantity);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: _decreaseQuantity,
        ),
        Container(
          width: 25,
          height: 25,
          color: Colors.white,
          child: Center(child: Text('$_quantity')),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: _increaseQuantity,
        ),
      ],
    );
  }
}
