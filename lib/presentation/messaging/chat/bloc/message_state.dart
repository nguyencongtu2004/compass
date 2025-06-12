part of 'message_bloc.dart';

abstract class MessageState extends Equatable {
  const MessageState();

  @override
  List<Object?> get props => [];
}

class MessageInitial extends MessageState {
  const MessageInitial();
}

class MessageLoading extends MessageState {
  const MessageLoading();
}

class MessagesLoaded extends MessageState {
  final String conversationId;
  final List<MessageModel> messages;

  const MessagesLoaded({required this.conversationId, required this.messages});

  @override
  List<Object?> get props => [conversationId, messages];
}

class MessageSent extends MessageState {
  const MessageSent();
}

class MessagesMarkedAsRead extends MessageState {
  const MessagesMarkedAsRead();
}

class MessageError extends MessageState {
  final String message;

  const MessageError(this.message);

  @override
  List<Object?> get props => [message];
}
