import 'package:flutter/material.dart';

enum CourierCategory {
  waitingConfirmation,
  onProcess,
  onShipping,
  arrived,
  finished
}
extension CourierExtension on CourierCategory {
  String get displayName {
    switch (this) {
      case CourierCategory.waitingConfirmation:
        return 'Waiting for Confirmation';
      case CourierCategory.onProcess:
        return 'On Process';
      case CourierCategory.onShipping:
        return 'On Shipping';
      case CourierCategory.arrived:
        return 'Arrived';
      case CourierCategory.finished:
        return 'Finished';
      default:
        return '';
    }
  }
}

