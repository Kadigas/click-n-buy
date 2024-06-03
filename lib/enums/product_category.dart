import 'package:flutter/material.dart';

enum ProductCategory {
  electronics,
  fashion,
  home,
  beauty,
  sports,
  toys,
}
extension ProductCategoryExtension on ProductCategory {
  String get displayName {
    switch (this) {
      case ProductCategory.electronics:
        return 'Electronics';
      case ProductCategory.fashion:
        return 'Fashion';
      case ProductCategory.home:
        return 'Home';
      case ProductCategory.beauty:
        return 'Beauty';
      case ProductCategory.sports:
        return 'Sports';
      case ProductCategory.toys:
        return 'Toys';
      default:
        return '';
    }
  }
}

