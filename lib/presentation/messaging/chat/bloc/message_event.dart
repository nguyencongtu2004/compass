part of 'message_bloc.dart';

abstract class MessageEvent extends Equatable {
  const MessageEvent();

  @override
  List<Object?> get props => [];
}

class LoadMessages extends MessageEvent {
  final String conversationId;

  const LoadMessages(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

class MessagesUpdated extends MessageEvent {
  final List<MessageModel> messages;

  const MessagesUpdated(this.messages);

  @override
  List<Object?> get props => [messages];
}

class SendMessage extends MessageEvent {
  final String conversationId;
  final String senderId;
  final String content;
  final MessageType type;

  const SendMessage({
    required this.conversationId,
    required this.senderId,
    required this.content,
    this.type = MessageType.text,
  });

  @override
  List<Object?> get props => [conversationId, senderId, content, type];
}

class MarkMessagesAsRead extends MessageEvent {
  final String conversationId;
  final String myUid;

  const MarkMessagesAsRead({required this.conversationId, required this.myUid});

  @override
  List<Object?> get props => [conversationId, myUid];
}

class ResetMessageState extends MessageEvent {
  const ResetMessageState();
}
