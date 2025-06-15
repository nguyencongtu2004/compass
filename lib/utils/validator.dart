import 'package:flutter/material.dart';
import 'package:minecraft_compass/config/l10n/localization_extensions.dart';

abstract class Validator {
  static String? validateEmail(String? value, BuildContext context) {
    if (value == null || value.isEmpty) {
      return context.l10n.emailIsRequired;
    }
    const emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    if (!RegExp(emailPattern).hasMatch(value)) {
      return context.l10n.invalidEmailFormat;
    }
    return null;
  }

  static String? validatePassword(String? value, BuildContext context) {
    if (value == null || value.isEmpty) {
      return context.l10n.passwordIsRequired;
    }
    if (value.length < 6) {
      return context.l10n.passwordMustBeAtLeast6CharactersLong;
    }
    return null;
  }

  static String? validateConfirmPassword(
    String? value,
    String? password,
    BuildContext context,
  ) {
    if (value == null || value.isEmpty) {
      return context.l10n.confirmPasswordIsRequired;
    }
    if (value != password) {
      return context.l10n.passwordsDoNotMatch;
    }
    return null;
  }

  static String? validateDisplayName(String? value, BuildContext context) {
    if (value == null || value.isEmpty) {
      return context.l10n.displayNameIsRequired;
    }
    if (value.trim().length < 2) {
      return context.l10n.displayNameMustBeAtLeast2CharactersLong;
    }
    return null;
  }

  static String? validateUsername(String? value, BuildContext context) {
    if (value == null || value.isEmpty) {
      return null; // Không cần thông báo lỗi nếu không có giá trị
    }
    if (value.trim().length < 3) {
      return context.l10n.usernameMustBeAtLeast3CharactersLong;
    }
    if (value.trim().length > 20) {
      return context.l10n.usernameCannotExceed20Characters;
    }
    // Kiểm tra format: chỉ chữ cái, số và gạch dưới
    const usernamePattern = r'^[a-zA-Z0-9_]+$';
    if (!RegExp(usernamePattern).hasMatch(value)) {
      return context.l10n.usernamesCanOnlyContainLettersNumbersAndUnderscores;
    }
    return null;
  }
}
