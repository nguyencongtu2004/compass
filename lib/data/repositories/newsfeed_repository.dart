import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/newsfeed_post_model.dart';

class NewsfeedRepository {
  final FirebaseFirestore _firestore;

  NewsfeedRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Tạo một bài đăng mới
  Future<void> createPost(NewsfeedPost post) async {
    await _firestore.collection('newsfeeds').add(post.toMap());
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
}
