import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../data/repositories/message_repository.dart';
import '../../../../models/conversation_model.dart';

part 'conversation_event.dart';
part 'conversation_state.dart';

@lazySingleton
class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final MessageRepository _messageRepository;

  StreamSubscription<List<ConversationModel>>? _conversationsSubscription;
  StreamSubscription<int>? _unreadCountSubscription;

  List<ConversationModel> _conversations = [];
  int _totalUnreadCount = 0;
  ConversationBloc({required MessageRepository messageRepository})
    : _messageRepository = messageRepository,
      super(const ConversationInitial()) {
    on<LoadConversations>(_onLoadConversations);
    on<ConversationsUpdated>(_onConversationsUpdated);
    on<CreateOrGetConversation>(_onCreateOrGetConversation);
    on<DeleteConversation>(_onDeleteConversation);
    on<LoadTotalUnreadCount>(_onLoadTotalUnreadCount);
    on<TotalUnreadCountUpdated>(_onTotalUnreadCountUpdated);
    on<ResetConversationState>(_onResetConversationState);
  }

  void _onLoadConversations(
    LoadConversations event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      emit(const ConversationLoading());

      // Load conversations
      _conversationsSubscription?.cancel();
      _conversationsSubscription = _messageRepository
          .getConversations(event.myUid)
          .listen((conversations) {
            add(ConversationsUpdated(conversations));
          });

      // Load total unread count
      add(LoadTotalUnreadCount(event.myUid));
    } catch (e) {
      emit(ConversationError('Không thể tải danh sách tin nhắn: $e'));
    }
  }

  void _onConversationsUpdated(
    ConversationsUpdated event,
    Emitter<ConversationState> emit,
  ) {
    _conversations = event.conversations;
    emit(
      ConversationsLoaded(
        conversations: _conversations,
        totalUnreadCount: _totalUnreadCount,
      ),
    );
  }

  void _onCreateOrGetConversation(
    CreateOrGetConversation event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      final conversation = await _messageRepository.createOrGetConversation(
        event.myUid,
        event.otherUid,
      );
      emit(ConversationCreated(conversation));
    } catch (e) {
      emit(ConversationError('Không thể tạo cuộc trò chuyện: $e'));
    }
  }

  void _onDeleteConversation(
    DeleteConversation event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      await _messageRepository.deleteConversation(event.conversationId);
      emit(const ConversationDeleted());
    } catch (e) {
      emit(ConversationError('Không thể xóa cuộc trò chuyện: $e'));
    }
  }

  void _onLoadTotalUnreadCount(
    LoadTotalUnreadCount event,
    Emitter<ConversationState> emit,
  ) {
    _unreadCountSubscription?.cancel();
    _unreadCountSubscription = _messageRepository
        .getTotalUnreadCount(event.myUid)
        .listen((count) {
          add(TotalUnreadCountUpdated(count));
        });
  }

  void _onTotalUnreadCountUpdated(
    TotalUnreadCountUpdated event,
    Emitter<ConversationState> emit,
  ) {
    _totalUnreadCount = event.count;
    emit(
      ConversationsLoaded(
        conversations: _conversations,
        totalUnreadCount: _totalUnreadCount,
      ),
    );
  }

  void _onResetConversationState(
    ResetConversationState event,
    Emitter<ConversationState> emit,
  ) {
    _conversationsSubscription?.cancel();
    _unreadCountSubscription?.cancel();

    _conversations = [];
    _totalUnreadCount = 0;

    emit(const ConversationInitial());
  }

  @override
  Future<void> close() {
    _conversationsSubscription?.cancel();
    _unreadCountSubscription?.cancel();
    return super.close();
  }
}
