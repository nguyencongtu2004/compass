part of 'conversation_bloc.dart';

abstract class ConversationState extends Equatable {
  const ConversationState();

  @override
  List<Object?> get props => [];
}

class ConversationInitial extends ConversationState {
  const ConversationInitial();
}

class ConversationLoading extends ConversationState {
  const ConversationLoading();
}

class ConversationsLoaded extends ConversationState {
  final List<ConversationModel> conversations;
  final int totalUnreadCount;

  const ConversationsLoaded({
    required this.conversations,
    required this.totalUnreadCount,
  });

  @override
  List<Object?> get props => [conversations, totalUnreadCount];
}

class ConversationCreated extends ConversationState {
  final ConversationModel conversation;

  const ConversationCreated(this.conversation);

  @override
  List<Object?> get props => [conversation];
}

class ConversationDeleted extends ConversationState {
  const ConversationDeleted();
}

class ConversationError extends ConversationState {
  final String message;

  const ConversationError(this.message);

  @override
  List<Object?> get props => [message];
}
