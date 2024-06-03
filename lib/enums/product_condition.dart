import 'package:flutter/material.dart';

enum ProductCondition {
  brandNew,
  used,
  refurbished,
}

extension ProductConditionExtension on ProductCondition {
  String get displayName {
    switch (this) {
      case ProductCondition.brandNew:
        return 'New';
      case ProductCondition.used:
        return 'Used';
      case ProductCondition.refurbished:
        return 'Refurbished';
      default:
        return '';
    }
  }
}