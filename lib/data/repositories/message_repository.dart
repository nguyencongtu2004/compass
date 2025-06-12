import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/conversation_model.dart';
import '../../models/message_model.dart';

class MessageRepository {
  final FirebaseFirestore _firestore;

  MessageRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Lấy danh sách conversations của user
  Stream<List<ConversationModel>> getConversations(String myUid) {
    return _firestore
        .collection('conversations')
        .where('participants', arrayContains: myUid)
        .orderBy('lastUpdatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ConversationModel.fromMap(doc.id, doc.data()))
              .toList();
        });
  }

  /// Tạo conversation mới hoặc lấy conversation hiện có
  Future<ConversationModel> createOrGetConversation(
    String uid1,
    String uid2,
  ) async {
    final conversationId = ConversationModel.generateConversationId(uid1, uid2);
    final docRef = _firestore.collection('conversations').doc(conversationId);

    final doc = await docRef.get();

    if (doc.exists) {
      return ConversationModel.fromMap(doc.id, doc.data()!);
    }

    // Tạo conversation mới nếu chưa tồn tại
    final newConversation = ConversationModel(
      id: conversationId,
      participants: [uid1, uid2],
      lastMessage: '',
      lastUpdatedAt: DateTime.now(),
      unreadCounts: {uid1: 0, uid2: 0},
    );

    await docRef.set(newConversation.toMap());
    return newConversation;
  }

  /// Lấy danh sách messages trong conversation
  Stream<List<MessageModel>> getMessages(String conversationId) {
    // TODO: Thêm pagination nếu cần thiết
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MessageModel.fromMap(doc.id, doc.data()))
              .toList();
        });
  }

  /// Gửi tin nhắn
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    final batch = _firestore.batch();

    // Thêm message mới
    final messageRef = _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc();

    final message = MessageModel(
      id: messageRef.id,
      senderId: senderId,
      content: content,
      createdAt: DateTime.now(),
      type: type,
    );

    batch.set(messageRef, message.toMap());

    // Cập nhật conversation
    final conversationRef = _firestore
        .collection('conversations')
        .doc(conversationId);

    // Lấy conversation hiện tại để cập nhật unreadCounts
    final conversationDoc = await conversationRef.get();
    if (conversationDoc.exists) {
      final conversation = ConversationModel.fromMap(
        conversationDoc.id,
        conversationDoc.data()!,
      );

      // Tăng unread count cho người nhận
      final newUnreadCounts = Map<String, int>.from(conversation.unreadCounts);
      for (final participantId in conversation.participants) {
        if (participantId != senderId) {
          newUnreadCounts[participantId] =
              (newUnreadCounts[participantId] ?? 0) + 1;
        }
      }

      final lastMessage = type == MessageType.text
          ? content
          : 'Đã gửi một tin nhắn mới';

      batch.update(conversationRef, {
        'lastMessage': lastMessage,
        'lastUpdatedAt': DateTime.now(),
        'unreadCounts': newUnreadCounts,
      });
    }

    await batch.commit();
  }

  /// Đánh dấu tin nhắn đã đọc
  Future<void> markMessagesAsRead(String conversationId, String myUid) async {
    final batch = _firestore.batch();

    // Lấy các tin nhắn chưa đọc
    final messagesSnapshot = await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .where('senderId', isNotEqualTo: myUid)
        .where('readAt', isNull: true)
        .get();

    // Đánh dấu đã đọc
    for (final doc in messagesSnapshot.docs) {
      batch.update(doc.reference, {'readAt': DateTime.now()});
    }

    // Reset unread count của user này
    final conversationRef = _firestore
        .collection('conversations')
        .doc(conversationId);

    batch.update(conversationRef, {'unreadCounts.$myUid': 0});

    await batch.commit();
  }

  /// Lấy số tin nhắn chưa đọc tổng
  Stream<int> getTotalUnreadCount(String myUid) {
    return _firestore
        .collection('conversations')
        .where('participants', arrayContains: myUid)
        .snapshots()
        .map((snapshot) {
          int totalUnread = 0;
          for (final doc in snapshot.docs) {
            final data = doc.data();
            final unreadCounts = Map<String, int>.from(
              data['unreadCounts'] ?? {},
            );
            totalUnread += unreadCounts[myUid] ?? 0;
          }
          return totalUnread;
        });
  }

  /// Xóa conversation
  Future<void> deleteConversation(String conversationId) async {
    final batch = _firestore.batch();

    // Xóa tất cả messages
    final messagesSnapshot = await _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .get();

    for (final doc in messagesSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Xóa conversation
    final conversationRef = _firestore
        .collection('conversations')
        .doc(conversationId);
    batch.delete(conversationRef);

    await batch.commit();
  }
}
