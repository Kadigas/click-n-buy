import 'package:flutter/material.dart';

Widget buildDropdownButtonFormField({
  required String? selectedValue,
  required String label,
  required List<Map<String, dynamic>> items,
  required ValueChanged<String?> onChanged,
}) {
  return DropdownButtonFormField<String>(
    value: selectedValue,
    decoration: InputDecoration(labelText: label),
    items: items
        .map((item) => DropdownMenuItem<String>(
      value: item['id'],
      child: Text(item['name']),
    ))
        .toList(),
    onChanged: onChanged,
    dropdownColor: Colors.white,
    isExpanded: true,
    itemHeight: 48,
    selectedItemBuilder: (context) {
      return items
          .map((item) => Text(
        item['name'],
        overflow: TextOverflow.ellipsis,
      ))
          .toList();
    },
    menuMaxHeight: 48.0 * 7,
  );
}
