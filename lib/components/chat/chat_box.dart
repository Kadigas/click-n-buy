import 'package:flutter/material.dart';
import 'package:fp_ppb/enums/chat_types.dart';
import 'package:fp_ppb/service/chat_service.dart';
import 'package:fp_ppb/service/image_cloud_service.dart';

class ChatBox extends StatefulWidget {
  final String? text;
  final bool isMe;
  final DateTime timestamp;
  final String? imageUrl;
  final MessageType messageType;
  final String idMessage;
  final Function(String messageId, Map<Object, Object?> editedDataObj)
      editMessage;
  final bool isDelete;
  final bool isEdit;
  final Function(String messageText, String messageId) setIsEditMode;

  const ChatBox({
    super.key,
    this.text,
    required this.isMe,
    required this.timestamp,
    this.imageUrl,
    required this.messageType,
    required this.idMessage,
    required this.editMessage,
    required this.isDelete,
    required this.isEdit,
    required this.setIsEditMode,
  });

  @override
  State<ChatBox> createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  bool isEditMode = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        if (widget.isMe) {
          showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (widget.messageType != MessageType.image &&
                        !widget.isDelete)
                      ListTile(
                        leading: const Icon(Icons.edit),
                        title: const Text('Edit'),
                        onTap: () async {
                          Navigator.pop(context);
                          widget.setIsEditMode(widget.text!, widget.idMessage);
                        },
                      ),
                    if (!widget.isDelete)
                      ListTile(
                        leading: const Icon(Icons.delete),
                        title: const Text('Delete'),
                        onTap: () async {
                          Navigator.pop(context);
                          await widget.editMessage(
                              widget.idMessage, {'isDelete': true});
                        },
                      ),
                  ],
                );
              });
        }
      },
      child: Column(
        crossAxisAlignment:
            widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!widget.isMe)
                const CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Text("A"), // Placeholder avatar
                ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  decoration: BoxDecoration(
                    color: widget.isMe ? Colors.blue : Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: widget.isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      widget.isDelete
                          ? Text(
                              "message is deleted",
                              style: TextStyle(
                                  color: widget.isMe
                                      ? Colors.white
                                      : Colors.black87,
                                  fontStyle: FontStyle.italic),
                            )
                          : (widget.messageType == MessageType.image &&
                                  widget.imageUrl != null)
                              ? Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Image.network(
                                    widget.imageUrl!,
                                    loadingBuilder: (BuildContext context,
                                        Widget child,
                                        ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  (loadingProgress
                                                          .expectedTotalBytes ??
                                                      1)
                                              : null,
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : (widget.text != null && widget.text!.isNotEmpty)
                                  ? Text(
                                      widget.text!,
                                      style: TextStyle(
                                        color: widget.isMe
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    )
                                  : Text(
                                      "error while loading message",
                                      style: TextStyle(
                                        color: widget.isMe
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    )
                    ],
                  ),
                ),
              ),
              if (widget.isMe)
                const CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Text("Me"), // Placeholder avatar for the current user
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              children: [
                Text(
                  "${widget.isEdit ? "edited" : ''} ${widget.timestamp.hour}:${widget.timestamp.minute}",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
