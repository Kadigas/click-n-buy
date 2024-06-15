import 'package:flutter/material.dart';

enum CourierCategory {
  waitingPayment,
  purchased,
  cancel,
}
extension CourierExtension on CourierCategory {
  String get displayName {
    switch (this) {
      case CourierCategory.waitingPayment:
        return 'Waiting for Payment';
      case CourierCategory.purchased:
        return 'Purchased';
      case CourierCategory.cancel:
        return 'Cancelled';
      default:
        return '';
    }
  }
}

