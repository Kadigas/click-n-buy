import 'package:flutter/material.dart';

enum CourierCategory {
  jne,
  pos,
  tiki,
}
extension CourierExtension on CourierCategory {
  String get displayName {
    switch (this) {
      case CourierCategory.jne:
        return 'JNE';
      case CourierCategory.pos:
        return 'POS Indonesia';
      case CourierCategory.tiki:
        return 'TIKI';
      default:
        return '';
    }
  }
}

