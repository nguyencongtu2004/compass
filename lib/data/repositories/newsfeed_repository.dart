import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minecraft_compass/utils/location_utils.dart';
import '../../models/newsfeed_post_model.dart';

class NewsfeedRepository {
  final FirebaseFirestore _firestore;

  NewsfeedRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;
  /// Tạo một bài đăng mới
  Future<void> createPost(NewsfeedPost post) async {
    await _firestore.collection('newsfeeds').add(post.toMap());
  }

  /// Lấy bài đăng theo ID
  Future<NewsfeedPost?> getPostById(String postId) async {
    try {
      final doc = await _firestore.collection('newsfeeds').doc(postId).get();
      if (!doc.exists) return null;

      return NewsfeedPost.fromMap(doc.id, doc.data()!);
    } catch (e) {
      return null;
    }
  }

  /// Lấy danh sách bài đăng theo thời gian (mới nhất trước)
  Future<List<NewsfeedPost>> getPosts({
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    Query query = _firestore
        .collection('newsfeeds')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }
    final querySnapshot = await query.get();

    return querySnapshot.docs
        .map(
          (doc) =>
              NewsfeedPost.fromMap(doc.id, doc.data() as Map<String, dynamic>),
        )
        .toList();
  }

  /// Lấy danh sách bài đăng với offset cho pagination đơn giản
  Future<List<NewsfeedPost>> getPostsWithOffset({
    int limit = 10,
    int offset = 0,
  }) async {
    final querySnapshot = await _firestore
        .collection('newsfeeds')
        .orderBy('createdAt', descending: true)
        .limit(limit + offset)
        .get();

    final allPosts = querySnapshot.docs
        .map((doc) => NewsfeedPost.fromMap(doc.id, doc.data()))
        .toList();

    // Return only the posts after the offset
    return allPosts.skip(offset).take(limit).toList();
  }

  /// Lấy bài đăng của một user cụ thể
  Future<List<NewsfeedPost>> getUserPosts(
    String userId, {
    int limit = 10,
  }) async {
    final querySnapshot = await _firestore
        .collection('newsfeeds')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return querySnapshot.docs
        .map((doc) => NewsfeedPost.fromMap(doc.id, doc.data()))
        .toList();
  }

  /// Xóa một bài đăng
  Future<void> deletePost(String postId) async {
    await _firestore.collection('newsfeeds').doc(postId).delete();
  }

  /// Lấy document snapshot cho pagination
  Future<DocumentSnapshot?> getDocumentSnapshot(String postId) async {
    try {
      final doc = await _firestore.collection('newsfeeds').doc(postId).get();
      return doc.exists ? doc : null;
    } catch (e) {
      return null;
    }
  }

  /// Stream để listen realtime updates
  Stream<List<NewsfeedPost>> getPostsStream({int limit = 10}) {
    return _firestore
        .collection('newsfeeds')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NewsfeedPost.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  /// Lấy các post gần vị trí hiện tại trong bán kính nhất định (loại trừ bạn bè nhưng bao gồm mình)
  /// radius: bán kính tính bằng mét
  /// excludeFriendUids: danh sách UID bạn bè cần loại trừ
  /// currentUserId: UID của user hiện tại (luôn được bao gồm)
  Future<List<NewsfeedPost>> getPostsByLocation({
    required double currentLat,
    required double currentLng,
    required double radiusInMeters,
    List<String>? excludeFriendUids,
    String? currentUserId,
    int limit = 20,
  }) async {
    try {
      // Phương pháp 1: Tìm posts trong bounding box (vì Firestore không hỗ trợ geo query trực tiếp)
      // Tính toán bounding box từ center và radius
      const double earthRadius = 6371000; // mét
      final double latDelta = radiusInMeters / earthRadius * (180 / math.pi);
      final double lngDelta =
          radiusInMeters /
          (earthRadius * math.pi / 180 * math.cos(currentLat * math.pi / 180));

      final double minLat = currentLat - latDelta;
      final double maxLat = currentLat + latDelta;
      final double minLng = currentLng - lngDelta;
      final double maxLng = currentLng + lngDelta;

      // Query tất cả posts và filter theo location
      final querySnapshot = await _firestore
          .collection('newsfeeds')
          .orderBy('createdAt', descending: true)
          .limit(100) // Lấy nhiều posts để filter
          .get();

      final posts = querySnapshot.docs
          .map((doc) => NewsfeedPost.fromMap(doc.id, doc.data()))
          .where((post) => post.location != null)
          .where((post) {
            // Filter bằng bounding box trước
            return post.location!.latitude >= minLat &&
                post.location!.latitude <= maxLat &&
                post.location!.longitude >= minLng &&
                post.location!.longitude <= maxLng;
          })
          .where((post) {
            // Filter chính xác bằng haversine distance
            final distance = LocationUtils.calculateDistance(
              currentLat,
              currentLng,
              post.location!.latitude,
              post.location!.longitude,
            );
            return distance <= radiusInMeters;
          })
          .where((post) {
            // Loại trừ bạn bè nếu có danh sách excludeFriendUids, nhưng luôn bao gồm current user
            if (excludeFriendUids != null && excludeFriendUids.isNotEmpty) {
              // Luôn bao gồm current user (nếu có)
              if (currentUserId != null && post.userId == currentUserId) {
                return true;
              }
              // Loại trừ bạn bè
              return !excludeFriendUids.contains(post.userId);
            }
            return true;
          })
          .take(limit)
          .toList();

      // Nếu không tìm thấy posts gần, fallback sang tất cả posts (loại trừ friends nhưng bao gồm mình)
      if (posts.isEmpty) {
        final fallbackPosts = querySnapshot.docs
            .map((doc) => NewsfeedPost.fromMap(doc.id, doc.data()))
            .where((post) {
              // Chỉ loại trừ bạn bè, không quan tâm location, nhưng luôn bao gồm current user
              if (excludeFriendUids != null && excludeFriendUids.isNotEmpty) {
                // Luôn bao gồm current user (nếu có)
                if (currentUserId != null && post.userId == currentUserId) {
                  return true;
                }
                // Loại trừ bạn bè
                return !excludeFriendUids.contains(post.userId);
              }
              return true;
            })
            .take(limit)
            .toList();
        return fallbackPosts;
      }

      return posts;
    } catch (e) {
      // Fallback: return all posts if geo query fails
      return getPosts(limit: limit);
    }
  }

  /// Lấy các post từ danh sách bạn bè (không giới hạn vị trí)
  Future<List<NewsfeedPost>> getPostsFromFriends({
    required List<String> friendUids,
    int limit = 20,
  }) async {
    if (friendUids.isEmpty) return [];

    final querySnapshot = await _firestore
        .collection('newsfeeds')
        .where('userId', whereIn: friendUids)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return querySnapshot.docs
        .map((doc) => NewsfeedPost.fromMap(doc.id, doc.data()))
        .toList();
  }

  /// Lấy các post từ mình và bạn bè (Feed mode)
  Future<List<NewsfeedPost>> getPostsFromSelfAndFriends({
    required String currentUserId,
    required List<String> friendUids,
    int limit = 20,
  }) async {
    // Tạo danh sách UIDs bao gồm mình và bạn bè
    final allUids = [currentUserId, ...friendUids];

    if (allUids.isEmpty) return [];

    final querySnapshot = await _firestore
        .collection('newsfeeds')
        .where('userId', whereIn: allUids)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return querySnapshot.docs
        .map((doc) => NewsfeedPost.fromMap(doc.id, doc.data()))
        .toList();
  }
}
