import 'package:equatable/equatable.dart';
import 'package:minecraft_compass/utils/prase_utils.dart';

class ConversationModel extends Equatable {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastUpdatedAt;
  final Map<String, int> unreadCounts;

  const ConversationModel({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastUpdatedAt,
    required this.unreadCounts,
  });

  factory ConversationModel.fromMap(String id, Map<String, dynamic> map) {
    return ConversationModel(
      id: id,
      participants: List<String>.from(map['participants'] ?? []),
      lastMessage: map['lastMessage'] ?? '',
      lastUpdatedAt: PraseUtils.parseDateTime(map['lastUpdatedAt']),
      unreadCounts: Map<String, int>.from(map['unreadCounts'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'lastUpdatedAt': lastUpdatedAt,
      'unreadCounts': unreadCounts,
    };
  }

  /// Tạo ID conversation từ 2 user IDs (sắp xếp lexicographically)
  static String generateConversationId(String uid1, String uid2) {
    final sortedUids = [uid1, uid2]..sort();
    return '${sortedUids[0]}_${sortedUids[1]}';
  }

  /// Lấy UID của người chat với mình
  String getOtherParticipantId(String myUid) {
    return participants.firstWhere((uid) => uid != myUid);
  }

  /// Lấy số tin nhắn chưa đọc của user
  int getUnreadCount(String uid) {
    return unreadCounts[uid] ?? 0;
  }

  ConversationModel copyWith({
    String? id,
    List<String>? participants,
    String? lastMessage,
    DateTime? lastUpdatedAt,
    Map<String, int>? unreadCounts,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      unreadCounts: unreadCounts ?? this.unreadCounts,
    );
  }

  @override
  List<Object?> get props => [
    id,
    participants,
    lastMessage,
    lastUpdatedAt,
    unreadCounts,
  ];
}
