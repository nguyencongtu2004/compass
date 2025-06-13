import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import '../../models/auth_exception.dart';

@lazySingleton
class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required GoogleSignIn googleSignIn,
  }) : _firebaseAuth = firebaseAuth,
       _firestore = firestore,
       _googleSignIn = googleSignIn;

  /// Đăng ký mới
  Future<User?> registerByEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
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
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(
        code: 'unknown',
        message: 'Đã xảy ra lỗi không xác định: $e',
      );
    }
  }

  /// Đăng nhập
  Future<User?> loginByEmail({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(
        code: 'unknown',
        message: 'Đã xảy ra lỗi không xác định: $e',
      );
    }
  }

  /// Đăng xuất
  Future<void> logout() async {
    // Sign out from Google if signed in
    if (isSignedInWithGoogle) {
      await _googleSignIn.signOut();
    }
    await _firebaseAuth.signOut();
  }

  /// Stream lắng nghe AuthStateChanges
  Stream<User?> get user => _firebaseAuth.authStateChanges();

  /// Lấy user hiện tại
  User? get currentUser => _firebaseAuth.currentUser;

  /// Gửi email reset password
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(
        code: 'unknown',
        message: 'Đã xảy ra lỗi không xác định: $e',
      );
    }
  }

  /// Đăng nhập bằng Google
  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        throw const AuthException(
          code: 'google-sign-in-cancelled',
          message: 'Đăng nhập Google đã bị hủy.',
        );
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Check if user document exists, if not create it
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          // Create new user document for Google sign-in users
          await _firestore.collection('users').doc(user.uid).set({
            'displayName': user.displayName ?? '',
            'username': '',
            'email': user.email ?? '',
            'avatarUrl': user.photoURL ?? '',
            'createdAt': FieldValue.serverTimestamp(),
            'currentLocation': null,
            'friends': <String>[],
            'friendRequests': <String>[],
          });
        }
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseAuthException(e);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw const AuthException(
        code: 'google-sign-in-failed',
        message: 'Đăng nhập Google thất bại.',
      );
    }
  }

  /// Đăng xuất khỏi Google
  Future<void> signOutFromGoogle() async {
    await _googleSignIn.signOut();
  }

  /// Kiểm tra xem user có đăng nhập bằng Google không
  bool get isSignedInWithGoogle => _googleSignIn.currentUser != null;
}
