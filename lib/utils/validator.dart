abstract class Validator {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    const emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    if (!RegExp(emailPattern).hasMatch(value)) {
      return 'Invalid email format';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  static String? validateDisplayName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Display name is required';
    }
    if (value.length < 2) {
      return 'Display name must be at least 2 characters long';
    }
    return null;
  }

  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username là bắt buộc';
    }
    if (value.length < 3) {
      return 'Username phải có ít nhất 3 ký tự';
    }
    if (value.length > 20) {
      return 'Username không được vượt quá 20 ký tự';
    }
    // Kiểm tra format: chỉ chữ cái, số và gạch dưới
    const usernamePattern = r'^[a-zA-Z0-9_]+$';
    if (!RegExp(usernamePattern).hasMatch(value)) {
      return 'Username chỉ được chứa chữ cái, số và dấu gạch dưới';
    }
    return null;
  }
}
