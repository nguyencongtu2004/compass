import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service để quản lý locale settings
@injectable
class LocaleService {
  static const String _localeKey = 'selected_locale';
  final SharedPreferences _prefs;

  LocaleService(this._prefs);

  /// Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'), // English
    Locale('vi', 'VN'), // Vietnamese
  ];

  /// Default fallback locale
  static const Locale fallbackLocale = Locale('en', 'US');

  /// Lấy locale đã lưu hoặc locale của hệ thống
  Locale getSavedLocale() {
    final languageCode = _prefs.getString(_localeKey);

    if (languageCode != null) {
      final locale = _getLocaleFromLanguageCode(languageCode);
      return locale;
    }

    // Nếu chưa có locale được lưu, sử dụng locale của hệ thống
    final systemLocale = _getSystemLocale();

    if (isSupported(systemLocale)) {
      return systemLocale;
    }

    return fallbackLocale;
  }

  /// Lấy locale của hệ thống
  Locale _getSystemLocale() {
    // Lấy locale từ hệ thống, mặc định là locale đầu tiên trong window
    final systemLocales = WidgetsBinding.instance.platformDispatcher.locales;

    if (systemLocales.isNotEmpty) {
      return systemLocales.first;
    }
    return fallbackLocale;
  }

  /// Lưu locale đã chọn
  Future<void> saveLocale(Locale locale) async {
    await _prefs.setString(_localeKey, locale.languageCode);
  }

  /// Lấy locale từ language code
  Locale _getLocaleFromLanguageCode(String languageCode) {
    return supportedLocales.firstWhere(
      (locale) => locale.languageCode == languageCode,
      orElse: () => fallbackLocale,
    );
  }

  /// Kiểm tra locale có được support không
  bool isSupported(Locale locale) {
    return supportedLocales.any(
      (supported) => supported.languageCode == locale.languageCode,
    );
  }

  /// Lấy tên hiển thị của locale
  String getLocaleName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'vi':
        return 'Tiếng Việt';
      default:
        return 'English';
    }
  }
}
