enum MessageType {
  text,
  image,
}

extension MessageTypeExtension on MessageType {
  String get value {
    switch (this) {
      case MessageType.text:
        return 'text';
      case MessageType.image:
        return 'image';
      default:
        return '';
    }
  }
}