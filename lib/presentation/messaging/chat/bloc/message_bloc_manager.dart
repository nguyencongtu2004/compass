import 'package:injectable/injectable.dart';

import 'message_bloc.dart';
import '../../../../data/repositories/message_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../models/user_model.dart';

/// Manager để quản lý lifecycle của MessageBloc instances
/// Mỗi conversation sẽ có một MessageBloc riêng và được cache
@singleton
class MessageBlocManager {
  final MessageRepository _messageRepository;
  final UserRepository _userRepository;
  final Map<String, MessageBloc> _messageBlocCache = {};
  final Map<String, UserModel> _userCache = {};

  MessageBlocManager({
    required MessageRepository messageRepository,
    required UserRepository userRepository,
  }) : _messageRepository = messageRepository,
       _userRepository = userRepository;

  /// Lấy MessageBloc cho conversation, tạo mới nếu chưa có
  MessageBloc getMessageBloc(String conversationId) {
    if (!_messageBlocCache.containsKey(conversationId)) {
      _messageBlocCache[conversationId] = MessageBloc(
        messageRepository: _messageRepository,
      );
    }
    return _messageBlocCache[conversationId]!;
  }

  /// Preload MessageBloc cho một conversation (không emit loading state)
  void preloadMessageBloc(String conversationId) {
    if (!_messageBlocCache.containsKey(conversationId)) {
      _messageBlocCache[conversationId] = MessageBloc(
        messageRepository: _messageRepository,
      );
      // Preload messages without showing loading
      _messageBlocCache[conversationId]!.add(LoadMessages(conversationId));
    }
  }

  /// Kiểm tra xem có nên preload conversation không (tránh gọi duplicate)
  bool shouldPreloadConversation(String conversationId, String otherUid) {
    return !_messageBlocCache.containsKey(conversationId) ||
        !_userCache.containsKey(otherUid);
  }

  /// Cache user info để tránh load lại
  Future<UserModel?> getCachedUser(String uid) async {
    if (_userCache.containsKey(uid)) {
      return _userCache[uid];
    }

    try {
      final user = await _userRepository.getUserByUid(uid);
      if (user != null) {
        _userCache[uid] = user;
      }
      return user;
    } catch (e) {
      return null;
    }
  }

  /// Preload user info
  Future<void> preloadUser(String uid) async {
    if (!_userCache.containsKey(uid)) {
      await getCachedUser(uid);
    }
  }

  /// Preload cả MessageBloc và User info
  Future<void> preloadConversation(
    String conversationId,
    String otherUid,
  ) async {
    // Preload message bloc
    preloadMessageBloc(conversationId);

    // Preload user info
    await preloadUser(otherUid);
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

  /// Xóa user cache
  void clearUserCache(String uid) {
    _userCache.remove(uid);
  }

  /// Xóa tất cả MessageBloc (thường dùng khi logout)
  void clearAll() {
    for (final messageBloc in _messageBlocCache.values) {
      messageBloc.close();
    }
    _messageBlocCache.clear();
    _userCache.clear();
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
