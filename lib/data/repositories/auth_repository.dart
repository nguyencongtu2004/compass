import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepository({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  /// Đăng ký mới
  Future<User?> registerByEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final cred = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user;
    if (user != null) {
      // Tạo document user trong Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'displayName': displayName,
        'username': '',
        'email': email,
        'avatarUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
        'currentLocation': null,
        'friends': <String>[],
        'friendRequests': <String>[],
      });
    }
    return user;
  }

  /// Đăng nhập
  Future<User?> loginByEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  /// Đăng xuất
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  /// Stream lắng nghe AuthStateChanges
  Stream<User?> get user => _firebaseAuth.authStateChanges();

  /// Lấy user hiện tại
  User? get currentUser => _firebaseAuth.currentUser;
}
