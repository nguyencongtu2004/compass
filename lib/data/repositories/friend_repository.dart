import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';

class FriendRepository {
  final FirebaseFirestore _firestore;

  FriendRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Lấy danh sách bạn bè
  Future<List<UserModel>> getFriends(String uid) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();
    if (!userDoc.exists) return [];

    final friendUids = List<String>.from(userDoc.data()!['friends'] ?? []);
    if (friendUids.isEmpty) return [];

    final friendDocs = await _firestore
        .collection('users')
        .where(FieldPath.documentId, whereIn: friendUids)
        .get();

    return friendDocs.docs
        .map((doc) => UserModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  /// Lấy danh sách yêu cầu kết bạn
  Future<List<UserModel>> getFriendRequests(String uid) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();
    if (!userDoc.exists) return [];

    final requestUids = List<String>.from(
      userDoc.data()!['friendRequests'] ?? [],
    );
    if (requestUids.isEmpty) return [];

    final requestDocs = await _firestore
        .collection('users')
        .where(FieldPath.documentId, whereIn: requestUids)
        .get();

    return requestDocs.docs
        .map((doc) => UserModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  /// Gửi yêu cầu kết bạn
  Future<void> sendFriendRequest({
    required String fromUid,
    required String toUid,
  }) async {
    // Kiểm tra trước khi gửi
    final toUserDoc = await _firestore.collection('users').doc(toUid).get();
    if (!toUserDoc.exists) {
      throw Exception('Người dùng không tồn tại');
    }

    final toUserData = toUserDoc.data()!;
    final friends = List<String>.from(toUserData['friends'] ?? []);
    final friendRequests = List<String>.from(
      toUserData['friendRequests'] ?? [],
    );

    // Kiểm tra nếu đã là bạn bè
    if (friends.contains(fromUid)) {
      throw Exception('Người này đã là bạn bè của bạn');
    }

    // Kiểm tra nếu đã gửi lời mời
    if (friendRequests.contains(fromUid)) {
      throw Exception('Bạn đã gửi lời mời kết bạn cho người này');
    }

    await _firestore.collection('users').doc(toUid).update({
      'friendRequests': FieldValue.arrayUnion([fromUid]),
    });
  }

  /// Chấp nhận yêu cầu kết bạn
  Future<void> acceptFriendRequest({
    required String myUid,
    required String requesterUid,
  }) async {
    final batch = _firestore.batch();

    // Thêm vào danh sách bạn bè của cả hai
    final myDoc = _firestore.collection('users').doc(myUid);
    final requesterDoc = _firestore.collection('users').doc(requesterUid);

    batch.update(myDoc, {
      'friends': FieldValue.arrayUnion([requesterUid]),
      'friendRequests': FieldValue.arrayRemove([requesterUid]),
    });

    batch.update(requesterDoc, {
      'friends': FieldValue.arrayUnion([myUid]),
    });

    await batch.commit();
  }

  /// Từ chối yêu cầu kết bạn
  Future<void> declineFriendRequest({
    required String myUid,
    required String requesterUid,
  }) async {
    await _firestore.collection('users').doc(myUid).update({
      'friendRequests': FieldValue.arrayRemove([requesterUid]),
    });
  }

  /// Xóa bạn bè
  Future<void> removeFriend({
    required String myUid,
    required String friendUid,
  }) async {
    final batch = _firestore.batch();

    // Xóa khỏi danh sách bạn bè của cả hai
    final myDoc = _firestore.collection('users').doc(myUid);
    final friendDoc = _firestore.collection('users').doc(friendUid);

    batch.update(myDoc, {
      'friends': FieldValue.arrayRemove([friendUid]),
    });

    batch.update(friendDoc, {
      'friends': FieldValue.arrayRemove([myUid]),
    });

    await batch.commit();
  }

  /// Tìm kiếm user theo email
  Future<UserModel?> findUserByEmail(String email) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) return null;

    final doc = querySnapshot.docs.first;
    return UserModel.fromMap(doc.id, doc.data());
  }
}
