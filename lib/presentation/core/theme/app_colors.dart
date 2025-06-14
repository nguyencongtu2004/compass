import 'package:flutter/material.dart';

/// Comprehensive color system with support for light and dark modes
class AppColors {
  // Primary colors - Blue theme for compass/navigation feel
  static const Color primaryLight = Color(0xFF1976D2); // Material Blue 700
  static const Color primaryDark = Color(0xFF64B5F6); // Material Blue 300

  static const Color primaryContainerLight = Color(0xFFE3F2FD); // Blue 50
  static const Color primaryContainerDark = Color(0xFF0D47A1); // Blue 900

  // Secondary colors - Complementary orange for navigation elements
  static const Color secondaryLight = Color(0xFFFF8F00); // Amber 800
  static const Color secondaryDark = Color(0xFFFFB74D); // Orange 300

  static const Color secondaryContainerLight = Color(0xFFFFF3E0); // Orange 50
  static const Color secondaryContainerDark = Color(0xFFE65100); // Orange 900

  // Background colors
  static const Color backgroundLight = Color(0xFFFFFBFE);
  static const Color backgroundDark = Color(0xFF121212);

  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  static const Color surfaceVariantLight = Color(0xFFF5F5F5);
  static const Color surfaceVariantDark = Color(0xFF2C2C2C);

  // Text colors
  static const Color onBackgroundLight = Color(0xFF1C1B1F);
  static const Color onBackgroundDark = Color(0xFFE6E1E5);

  static const Color onSurfaceLight = Color(0xFF1C1B1F);
  static const Color onSurfaceDark = Color(0xFFE6E1E5);

  static const Color onSurfaceVariantLight = Color(0xFF49454F);
  static const Color onSurfaceVariantDark = Color(0xFFCAC4D0);

  // Status colors
  static const Color successLight = Color(0xFF2E7D32); // Green 800
  static const Color successDark = Color(0xFF66BB6A); // Green 400

  static const Color warningLight = Color(0xFFED6C02); // Orange 800
  static const Color warningDark = Color(0xFFFFB74D); // Orange 300

  static const Color errorLight = Color(0xFFD32F2F); // Red 700
  static const Color errorDark = Color(0xFFEF5350); // Red 400

  static const Color infoLight = Color(0xFF0288D1); // Light Blue 700
  static const Color infoDark = Color(0xFF4FC3F7); // Light Blue 300
  // Border colors
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF424242);

  static const Color outlineLight = Color(0xFF79747E);
  static const Color outlineDark = Color(0xFF938F99);

  // Input và message bubble background (khác với surfaceVariant)
  static const Color inputBackgroundLight = Color(
    0xFFF0F0F0,
  ); // Xám nhạt hơn surfaceVariant
  static const Color inputBackgroundDark = Color(
    0xFF383838,
  ); // Xám đậm hơn surfaceVariant

  // Compass specific colors
  static const Color compassNeedleLight = Color(0xFFD32F2F); // Red for north
  static const Color compassNeedleDark = Color(0xFFFF5252);

  static const Color compassBackgroundLight = Color(0xFFFFFBFE);
  static const Color compassBackgroundDark = Color(0xFF2C2C2C);

  static const Color compassRingLight = Color(0xFF1976D2);
  static const Color compassRingDark = Color(0xFF64B5F6);

  // Static methods to get theme-specific colors
  static Color primary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? primaryLight
        : primaryDark;
  }

  static Color secondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? secondaryLight
        : secondaryDark;
  }

  static Color background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? backgroundLight
        : backgroundDark;
  }

  static Color surface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? surfaceLight
        : surfaceDark;
  }

  static Color onBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? onBackgroundLight
        : onBackgroundDark;
  }

  static Color onSurface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? onSurfaceLight
        : onSurfaceDark;
  }

  static Color success(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? successLight
        : successDark;
  }

  static Color warning(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? warningLight
        : warningDark;
  }

  static Color error(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? errorLight
        : errorDark;
  }

  static Color info(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? infoLight
        : infoDark;
  }

  static Color border(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? borderLight
        : borderDark;
  }

  static Color compassNeedle(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? compassNeedleLight
        : compassNeedleDark;
  }

  static Color compassBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? compassBackgroundLight
        : compassBackgroundDark;
  }

  static Color compassRing(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? compassRingLight
        : compassRingDark;
  }

  // Additional helper methods for complete theme coverage
  static Color onPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? Colors.white
        : Color(0xFF003258);
  }

  static Color onSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? Colors.white
        : Color(0xFF4D2C00);
  }

  static Color onError(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? Colors.white
        : Colors.black;
  }

  static Color primaryContainer(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? primaryContainerLight
        : primaryContainerDark;
  }

  static Color onPrimaryContainer(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? Color(0xFF001E30)
        : Color(0xFFCCE8FF);
  }

  static Color secondaryContainer(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? secondaryContainerLight
        : secondaryContainerDark;
  }

  static Color onSecondaryContainer(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? Color(0xFF2D1600)
        : Color(0xFFFFDCC0);
  }

  static Color surfaceVariant(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? surfaceVariantLight
        : surfaceVariantDark;
  }

  static Color onSurfaceVariant(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? onSurfaceVariantLight
        : onSurfaceVariantDark;
  }
  static Color outline(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? outlineLight
        : outlineDark;
  }

  static Color inputBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? inputBackgroundLight
        : inputBackgroundDark;
  }
}
