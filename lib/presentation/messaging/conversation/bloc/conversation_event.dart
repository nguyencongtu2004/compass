part of 'conversation_bloc.dart';

abstract class ConversationEvent extends Equatable {
  const ConversationEvent();

  @override
  List<Object?> get props => [];
}

class LoadConversations extends ConversationEvent {
  final String myUid;

  const LoadConversations(this.myUid);

  @override
  List<Object?> get props => [myUid];
}

class ConversationsUpdated extends ConversationEvent {
  final List<ConversationModel> conversations;

  const ConversationsUpdated(this.conversations);

  @override
  List<Object?> get props => [conversations];
}

class CreateOrGetConversation extends ConversationEvent {
  final String myUid;
  final String otherUid;

  const CreateOrGetConversation({required this.myUid, required this.otherUid});

  @override
  List<Object?> get props => [myUid, otherUid];
}

class DeleteConversation extends ConversationEvent {
  final String conversationId;

  const DeleteConversation(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

class LoadTotalUnreadCount extends ConversationEvent {
  final String myUid;

  const LoadTotalUnreadCount(this.myUid);

  @override
  List<Object?> get props => [myUid];
}

class TotalUnreadCountUpdated extends ConversationEvent {
  final int count;

  const TotalUnreadCountUpdated(this.count);

  @override
  List<Object?> get props => [count];
}

class ResetConversationState extends ConversationEvent {
  const ResetConversationState();
}
