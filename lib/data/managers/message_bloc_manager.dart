import 'package:injectable/injectable.dart';

import '../../presentation/messaging/chat/bloc/message_bloc.dart';
import '../repositories/message_repository.dart';

/// Manager để quản lý lifecycle của MessageBloc instances
/// Mỗi conversation sẽ có một MessageBloc riêng và được cache
@singleton
class MessageBlocManager {
  final MessageRepository _messageRepository;
  final Map<String, MessageBloc> _messageBlocCache = {};

  MessageBlocManager({required MessageRepository messageRepository})
    : _messageRepository = messageRepository;

  /// Lấy MessageBloc cho conversation, tạo mới nếu chưa có
  MessageBloc getMessageBloc(String conversationId) {
    if (!_messageBlocCache.containsKey(conversationId)) {
      _messageBlocCache[conversationId] = MessageBloc(
        messageRepository: _messageRepository,
      );
    }
    return _messageBlocCache[conversationId]!;
  }

  /// Kiểm tra xem conversation có MessageBloc trong cache không
  bool hasMessageBloc(String conversationId) {
    return _messageBlocCache.containsKey(conversationId);
  }

  /// Xóa MessageBloc cho một conversation cụ thể
  void clearConversation(String conversationId) {
    final messageBloc = _messageBlocCache.remove(conversationId);
    messageBloc?.close();
  }

  /// Xóa tất cả MessageBloc (thường dùng khi logout)
  void clearAll() {
    for (final messageBloc in _messageBlocCache.values) {
      messageBloc.close();
    }
    _messageBlocCache.clear();
  }

  /// Lấy danh sách conversation IDs hiện có trong cache
  List<String> getCachedConversationIds() {
    return _messageBlocCache.keys.toList();
  }

  /// Cleanup khi dispose app
  void dispose() {
    clearAll();
  }
}
