import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/repositories/message_repository.dart';
import '../../../../models/message_model.dart';

part 'message_event.dart';
part 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final MessageRepository _messageRepository;

  StreamSubscription<List<MessageModel>>? _messagesSubscription;
  List<MessageModel> _messages = [];
  String? _currentConversationId;

  MessageBloc({required MessageRepository messageRepository})
    : _messageRepository = messageRepository,
      super(const MessageInitial()) {
    on<LoadMessages>(_onLoadMessages);
    on<MessagesUpdated>(_onMessagesUpdated);
    on<SendMessage>(_onSendMessage);
    on<MarkMessagesAsRead>(_onMarkMessagesAsRead);
    on<ResetMessageState>(_onResetMessageState);
  }
  void _onLoadMessages(LoadMessages event, Emitter<MessageState> emit) async {
    try {
      _currentConversationId = event.conversationId;

      // Nếu đã có messages cached cho conversation này, emit ngay lập tức
      if (_messages.isNotEmpty &&
          _currentConversationId == event.conversationId) {
        emit(
          MessagesLoaded(
            conversationId: event.conversationId,
            messages: _messages,
          ),
        );
      } else {
        // Emit MessagesLoaded với danh sách trống ngay lập tức để tránh loading
        emit(
          MessagesLoaded(
            conversationId: event.conversationId,
            messages: const [],
          ),
        );
      }

      _messagesSubscription?.cancel();
      _messagesSubscription = _messageRepository
          .getMessages(event.conversationId)
          .listen((messages) {
            add(MessagesUpdated(messages));
          });
    } catch (e) {
      emit(MessageError('Không thể tải tin nhắn: $e'));
    }
  }

  void _onMessagesUpdated(MessagesUpdated event, Emitter<MessageState> emit) {
    _messages = event.messages;
    if (_currentConversationId != null) {
      emit(
        MessagesLoaded(
          conversationId: _currentConversationId!,
          messages: _messages,
        ),
      );
    }
  }

  void _onSendMessage(SendMessage event, Emitter<MessageState> emit) async {
    try {
      await _messageRepository.sendMessage(
        conversationId: event.conversationId,
        senderId: event.senderId,
        content: event.content,
        type: event.type,
      );

      emit(const MessageSent());

      // Emit lại messages loaded để UI cập nhật với danh sách messages hiện tại
      if (_currentConversationId == event.conversationId) {
        emit(
          MessagesLoaded(
            conversationId: _currentConversationId!,
            messages: _messages,
          ),
        );
      }
    } catch (e) {
      // Emit error nhưng vẫn giữ messages hiện tại để không mất UI
      emit(MessageError('Không thể gửi tin nhắn: $e'));

      // Emit lại messages loaded để UI không bị mất
      if (_currentConversationId == event.conversationId) {
        emit(
          MessagesLoaded(
            conversationId: _currentConversationId!,
            messages: _messages,
          ),
        );
      }
    }
  }

  void _onMarkMessagesAsRead(
    MarkMessagesAsRead event,
    Emitter<MessageState> emit,
  ) async {
    try {
      await _messageRepository.markMessagesAsRead(
        event.conversationId,
        event.myUid,
      );
      emit(const MessagesMarkedAsRead());

      // Emit lại MessagesLoaded state để UI cập nhật
      if (_currentConversationId == event.conversationId) {
        emit(
          MessagesLoaded(
            conversationId: _currentConversationId!,
            messages: _messages,
          ),
        );
      }
    } catch (e) {
      // Emit error nhưng vẫn giữ messages hiện tại
      emit(MessageError('Không thể đánh dấu đã đọc: $e'));

      // Emit lại messages loaded để UI không bị mất
      if (_currentConversationId == event.conversationId) {
        emit(
          MessagesLoaded(
            conversationId: _currentConversationId!,
            messages: _messages,
          ),
        );
      }
    }
  }

  void _onResetMessageState(
    ResetMessageState event,
    Emitter<MessageState> emit,
  ) {
    _messagesSubscription?.cancel();

    _messages = [];
    _currentConversationId = null;

    emit(const MessageInitial());
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
