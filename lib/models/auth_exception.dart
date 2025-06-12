
/// Custom exception class cho authentication errors
class AuthException implements Exception {
  final String code;
  final String message;

  const AuthException({
    required this.code,
    required this.message,
  });

  /// Factory constructor để tạo AuthException từ FirebaseAuthException
  factory AuthException.fromFirebaseAuthException(dynamic exception) {
    String code = 'unknown';
    String message = 'An unknown error occurred';

    if (exception.code != null) {
      code = exception.code;
    }

    switch (code) {
      case 'user-not-found':
        message = 'Không tìm thấy tài khoản với email này.';
        break;
      case 'wrong-password':
        message = 'Mật khẩu không chính xác.';
        break;
      case 'email-already-in-use':
        message = 'Email này đã được sử dụng cho tài khoản khác.';
        break;
      case 'weak-password':
        message = 'Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn.';
        break;
      case 'invalid-email':
        message = 'Địa chỉ email không hợp lệ.';
        break;
      case 'operation-not-allowed':
        message = 'Thao tác này không được phép.';
        break;
      case 'user-disabled':
        message = 'Tài khoản đã bị vô hiệu hóa.';
        break;
      case 'invalid-credential':
        message = 'Thông tin đăng nhập không hợp lệ.';
        break;
      case 'account-exists-with-different-credential':
        message = 'Tài khoản đã tồn tại với phương thức đăng nhập khác.';
        break;
      case 'requires-recent-login':
        message = 'Thao tác này yêu cầu đăng nhập gần đây.';
        break;
      case 'credential-already-in-use':
        message = 'Thông tin đăng nhập này đã được sử dụng.';
        break;
      case 'invalid-verification-code':
        message = 'Mã xác thực không hợp lệ.';
        break;
      case 'invalid-verification-id':
        message = 'ID xác thực không hợp lệ.';
        break;
      case 'network-request-failed':
        message = 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet.';
        break;
      case 'too-many-requests':
        message = 'Quá nhiều yêu cầu. Vui lòng thử lại sau.';
        break;
      case 'google-sign-in-cancelled':
        message = 'Đăng nhập Google đã bị hủy.';
        break;
      case 'google-sign-in-failed':
        message = 'Đăng nhập Google thất bại.';
        break;
      default:
        message = exception.message ?? 'Đã xảy ra lỗi không xác định.';
    }

    return AuthException(code: code, message: message);
  }

  @override
  String toString() {
    return 'AuthException(code: $code, message: $message)';
  }
}
