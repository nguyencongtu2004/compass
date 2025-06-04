import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Comprehensive text style system for the app
class AppTextStyles {
  // Base font family
  static const String _fontFamily =
      'SF Pro Display'; // iOS style for modern look

  // Display styles - largest text
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    fontFamily: _fontFamily,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFamily: _fontFamily,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFamily: _fontFamily,
  );

  // Headline styles - prominent text
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFamily: _fontFamily,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFamily: _fontFamily,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFamily: _fontFamily,
  );

  // Title styles - medium emphasis text
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    fontFamily: _fontFamily,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    fontFamily: _fontFamily,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    fontFamily: _fontFamily,
  );

  // Label styles - high emphasis short text
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    fontFamily: _fontFamily,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    fontFamily: _fontFamily,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    fontFamily: _fontFamily,
  );

  // Body styles - main content text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    fontFamily: _fontFamily,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    fontFamily: _fontFamily,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    fontFamily: _fontFamily,
  );

  // App-specific styles

  // Login/Register screens
  static const TextStyle appTitle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    fontFamily: _fontFamily,
  );

  static const TextStyle appSubtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    fontFamily: _fontFamily,
  );

  // Button styles
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    fontFamily: _fontFamily,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.25,
    fontFamily: _fontFamily,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    fontFamily: _fontFamily,
  );

  // Navigation styles
  static const TextStyle navigationTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    fontFamily: _fontFamily,
  );

  static const TextStyle tabLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    fontFamily: _fontFamily,
  );

  // Compass specific styles
  static const TextStyle compassCoordinate = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    fontFamily: 'SF Mono', // Monospace for coordinates
  );

  static const TextStyle compassDistance = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    fontFamily: _fontFamily,
  );

  static const TextStyle compassBearing = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.25,
    fontFamily: _fontFamily,
  );

  // Form styles
  static const TextStyle formLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    fontFamily: _fontFamily,
  );

  static const TextStyle formError = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    fontFamily: _fontFamily,
  );

  static const TextStyle formHint = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    fontFamily: _fontFamily,
  );

  // Helper methods to get themed text styles
  static TextStyle getThemedStyle({
    required TextStyle baseStyle,
    required BuildContext context,
    Color? color,
  }) {
    return baseStyle.copyWith(color: color ?? AppColors.onSurface(context));
  }

  static TextStyle primary(BuildContext context, TextStyle baseStyle) {
    return baseStyle.copyWith(color: AppColors.primary(context));
  }

  static TextStyle secondary(BuildContext context, TextStyle baseStyle) {
    return baseStyle.copyWith(color: AppColors.secondary(context));
  }

  static TextStyle error(BuildContext context, TextStyle baseStyle) {
    return baseStyle.copyWith(color: AppColors.error(context));
  }

  static TextStyle success(BuildContext context, TextStyle baseStyle) {
    return baseStyle.copyWith(color: AppColors.success(context));
  }

  static TextStyle warning(BuildContext context, TextStyle baseStyle) {
    return baseStyle.copyWith(color: AppColors.warning(context));
  }

  static TextStyle onSurface(BuildContext context, TextStyle baseStyle) {
    return baseStyle.copyWith(color: AppColors.onSurface(context));
  }

  static TextStyle onBackground(BuildContext context, TextStyle baseStyle) {
    return baseStyle.copyWith(color: AppColors.onBackground(context));
  }
}
