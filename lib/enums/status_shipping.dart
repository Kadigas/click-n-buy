import 'package:flutter/material.dart';

enum StatusShipping {
  unpaid,
  waitingConfirmation,
  onProcess,
  onShipping,
  arrived,
  finished
}
extension StatusShippingExtension on StatusShipping {
  String get displayName {
    switch (this) {
      case StatusShipping.unpaid:
        return 'Unpaid';
      case StatusShipping.waitingConfirmation:
        return 'Waiting for Confirmation';
      case StatusShipping.onProcess:
        return 'On Process';
      case StatusShipping.onShipping:
        return 'On Shipping';
      case StatusShipping.arrived:
        return 'Arrived';
      case StatusShipping.finished:
        return 'Finished';
      default:
        return '';
    }
  }
}