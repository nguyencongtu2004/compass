import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../services/cloudinary_service.dart';

class UserRepository {
  final FirebaseFirestore _firestore;
  final CloudinaryService _cloudinaryService;

  UserRepository({
    FirebaseFirestore? firestore,
    CloudinaryService? cloudinaryService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _cloudinaryService = cloudinaryService ?? CloudinaryService();

  /// Lấy thông tin user theo uid
  Future<UserModel?> getUserByUid(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromMap(uid, doc.data()!);
    } catch (e) {
      throw Exception('Không thể tải thông tin người dùng: $e');
    }
  }

  /// Cập nhật thông tin profile người dùng
  Future<void> updateProfile({
    required String uid,
    String? displayName,
    String? username,
    File? avatarFile,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};

      // Cập nhật tên hiển thị
      if (displayName != null && displayName.isNotEmpty) {
        updateData['displayName'] = displayName;
      }

      // Cập nhật username (kiểm tra tính duy nhất)
      if (username != null && username.isNotEmpty) {
        await _validateUsername(username, uid);
        updateData['username'] = username;
      } // Upload và cập nhật avatar
      if (avatarFile != null) {
        // Sử dụng method chuyên dụng để upload avatar với public_id cố định
        final avatarUrl = await _cloudinaryService.uploadUserAvatar(
          avatarFile,
          uid,
        );
        if (avatarUrl != null) {
          updateData['avatarUrl'] = avatarUrl;
        }
      }

      // Cập nhật vào Firestore
      if (updateData.isNotEmpty) {
        await _firestore.collection('users').doc(uid).update(updateData);
      }
    } catch (e) {
      throw Exception('Không thể cập nhật profile: $e');
    }
  }

  /// Kiểm tra tính duy nhất của username
  Future<void> _validateUsername(String username, String currentUid) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    // Nếu tìm thấy user khác với username này
    if (querySnapshot.docs.isNotEmpty) {
      final existingUser = querySnapshot.docs.first;
      if (existingUser.id != currentUid) {
        throw Exception('Tên người dùng đã được sử dụng');
      }
    }
  }

  /// Kiểm tra username có khả dụng không
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();
      return querySnapshot.docs.isEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Tìm user theo username
  Future<UserModel?> findUserByUsername(String username) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      final doc = querySnapshot.docs.first;
      return UserModel.fromMap(doc.id, doc.data());
    } catch (e) {
      throw Exception('Không thể tìm người dùng: $e');
    }
  }
}
