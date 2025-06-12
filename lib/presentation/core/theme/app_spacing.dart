import 'package:flutter/material.dart';

/// App spacing constants based on a consistent scale
abstract class AppSpacing {
  // Base spacing unit (8px)
  static const double _baseUnit = 8.0;

  // Micro spacing (2-4px) - for very tight layouts
  static const double micro = _baseUnit * 0.25; // 2px
  static const double micro2 = _baseUnit * 0.5; // 4px

  // Extra small spacing (4-8px) - for tight layouts
  static const double xs = _baseUnit * 0.5; // 4px
  static const double xs2 = _baseUnit; // 8px

  // Small spacing (8-16px) - common for padding/margins
  static const double sm = _baseUnit; // 8px
  static const double sm2 = _baseUnit * 1.5; // 12px
  static const double sm3 = _baseUnit * 2; // 16px

  // Medium spacing (16-32px) - for sections
  static const double md = _baseUnit * 2; // 16px
  static const double md2 = _baseUnit * 2.5; // 20px
  static const double md3 = _baseUnit * 3; // 24px
  static const double md4 = _baseUnit * 4; // 32px

  // Large spacing (32-64px) - for major sections
  static const double lg = _baseUnit * 4; // 32px
  static const double lg2 = _baseUnit * 5; // 40px
  static const double lg3 = _baseUnit * 6; // 48px
  static const double lg4 = _baseUnit * 8; // 64px

  // Extra large spacing (64px+) - for major separations
  static const double xl = _baseUnit * 8; // 64px
  static const double xl2 = _baseUnit * 10; // 80px
  static const double xl3 = _baseUnit * 12; // 96px
  static const double xl4 = _baseUnit * 16; // 128px

  // Special purpose spacing
  static const double none = 0;
  static const double divider = 1;
  static const double border = 1;
  static const double border2 = 2;
  static const double border3 = 3;
  // Component specific spacing
  static const double buttonPadding = md; // 16px
  static const double buttonHeight = lg2; // 40px
  static const double cardPadding = md3; // 24px
  static const double screenPadding = md; // 16px
  static const double sectionPadding = md4; // 32px

  // Icon sizes
  static const double iconXs = _baseUnit * 2; // 16px
  static const double iconSm = _baseUnit * 2.5; // 20px
  static const double iconMd = _baseUnit * 3; // 24px
  static const double iconLg = _baseUnit * 4; // 32px
  static const double iconXl = _baseUnit * 6; // 48px
  static const double iconXxl = _baseUnit * 8; // 64px

  // Border radius
  static const double radiusXs = 2;
  static const double radiusSm = 4;
  static const double radiusMd = 8;
  static const double radiusLg = 12;
  static const double radiusXl = 16;
  static const double radiusXxl = 24;
  static const double radiusRound = 50; // For circular elements

  // Elevation
  static const double elevation0 = 0;
  static const double elevation1 = 1;
  static const double elevation2 = 2;
  static const double elevation3 = 3;
  static const double elevation4 = 4;
  static const double elevation6 = 6;
  static const double elevation8 = 8;
  static const double elevation12 = 12;
  static const double elevation16 = 16;
  static const double elevation24 = 24;

  // Compass specific spacing
  static const double compassSize = _baseUnit * 31.25; // 250px
  static const double compassNeedleLength = _baseUnit * 12.5; // 100px
  static const double compassRingWidth = _baseUnit * 0.5; // 4px

  /// Calculate the height of the toolbar including the status bar
  static double toolBarHeight(BuildContext context) {
    return kToolbarHeight + MediaQuery.of(context).padding.top;
  }
}
