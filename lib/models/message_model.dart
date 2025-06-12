import 'package:equatable/equatable.dart';
import 'package:minecraft_compass/utils/prase_utils.dart';

enum MessageType {
  text,
  post;

  static MessageType fromString(String? type) {
    switch (type) {
      case 'text':
        return MessageType.text;
      case 'post':
        return MessageType.post;
      default:
        return MessageType.text;
    }
  }

  String get value {
    switch (this) {
      case MessageType.text:
        return 'text';
      case MessageType.post:
        return 'post';
    }
  }
}

class MessageModel extends Equatable {
  final String id;
  final String senderId;
  final String content;
  final DateTime createdAt;
  final DateTime? readAt;
  final MessageType type;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.readAt,
    this.type = MessageType.text,
  });

  factory MessageModel.fromMap(String id, Map<String, dynamic> map) {
    return MessageModel(
      id: id,
      senderId: map['senderId'] ?? '',
      content: map['content'] ?? '',
      createdAt: PraseUtils.parseDateTime(map['createdAt']),
      readAt: map['readAt'] != null
          ? PraseUtils.parseDateTime(map['readAt'])
          : null,
      type: MessageType.fromString(map['type']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'content': content,
      'createdAt': createdAt,
      'readAt': readAt,
      'type': type.value,
    };
  }

  /// Kiểm tra tin nhắn đã được đọc chưa
  bool get isRead => readAt != null;

  /// Kiểm tra tin nhắn có phải là post không
  bool get isPost => type == MessageType.post;

  /// Kiểm tra tin nhắn có phải là text không
  bool get isText => type == MessageType.text;

  MessageModel copyWith({
    String? id,
    String? senderId,
    String? content,
    DateTime? createdAt,
    DateTime? readAt,
    MessageType? type,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      type: type ?? this.type,
    );
  }

  @override
  List<Object?> get props => [id, senderId, content, createdAt, readAt, type];
}
