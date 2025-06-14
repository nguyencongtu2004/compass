import 'package:flutter/material.dart';
import 'package:minecraft_compass/config/l10n/app_localizations.dart';

/// Extension để dễ dàng truy cập localization trong BuildContext
extension LocalizationExtension on BuildContext {
  /// Truy cập AppLocalizations thông qua context
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  /// Truy cập Locale hiện tại
  Locale get locale => Localizations.localeOf(this);

  /// Kiểm tra locale hiện tại có phải tiếng Việt không
  bool get isVietnamese => locale.languageCode == 'vi';

  /// Kiểm tra locale hiện tại có phải tiếng Anh không
  bool get isEnglish => locale.languageCode == 'en';
}

/// Extension để format thời gian với localization
extension DateTimeLocalization on DateTime {
  /// Format thời gian relative (ví dụ: "2 giờ trước")
  String formatRelative(BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inMinutes < 1) {
      return context.l10n.now;
    } else if (difference.inHours < 1) {
      return context.l10n.minutesAgo(difference.inMinutes);
    } else if (difference.inDays < 1) {
      return context.l10n.hoursAgo(difference.inHours);
    } else {
      return context.l10n.daysAgo(difference.inDays);
    }
  }
}

/// Utility class để quản lý supported locales
class SupportedLocales {
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'), // English
    Locale('vi', 'VN'), // Vietnamese
  ];

  static const Locale fallbackLocale = Locale('en', 'US');

  /// Lấy locale từ language code
  static Locale getLocaleFromLanguageCode(String languageCode) {
    return supportedLocales.firstWhere(
      (locale) => locale.languageCode == languageCode,
      orElse: () => fallbackLocale,
    );
  }

  /// Kiểm tra locale có được support không
  static bool isSupported(Locale locale) {
    return supportedLocales.any(
      (supported) => supported.languageCode == locale.languageCode,
    );
  }
}
