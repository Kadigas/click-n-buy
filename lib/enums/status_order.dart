import 'package:flutter/material.dart';

enum StatusOrder {
  waitingPayment,
  purchased,
  cancel,
}
extension StatusOrderExtension on StatusOrder {
  String get displayName {
    switch (this) {
      case StatusOrder.waitingPayment:
        return 'Waiting for Payment';
      case StatusOrder.purchased:
        return 'Purchased';
      case StatusOrder.cancel:
        return 'Cancelled';
      default:
        return '';
    }
  }
}