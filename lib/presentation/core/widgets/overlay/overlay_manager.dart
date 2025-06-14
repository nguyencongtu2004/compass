import 'package:flutter/material.dart';
import 'package:minecraft_compass/presentation/core/widgets/overlay/animated_emoji_overlay.dart';
import 'package:minecraft_compass/presentation/core/widgets/overlay/loading_widget.dart';
import 'package:minecraft_compass/presentation/core/widgets/overlay/toast_types.dart';
import 'package:minecraft_compass/presentation/core/widgets/overlay/toast_widget.dart';

/// Manager class để hiển thị các overlay notifications
class OverlayManager {
  static OverlayEntry? _currentToastEntry;

  /// Hiển thị toast notification
  static void showToast(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    ToastPosition position = ToastPosition.bottom,
    Duration duration = const Duration(seconds: 3),
    String? customIcon,
    Color? customColor,
    VoidCallback? onTap,
  }) {
    // Xóa toast hiện tại nếu có
    _dismissCurrentToast();

    final overlay = Overlay.of(context);
    _currentToastEntry = OverlayEntry(
      builder: (context) => ToastWidget(
        message: message,
        type: type,
        position: position,
        duration: duration,
        customIcon: customIcon,
        customColor: customColor,
        onTap: onTap,
        onDismiss: _dismissCurrentToast,
      ),
    );

    overlay.insert(_currentToastEntry!);
  }

  /// Hiển thị toast error với animation đặc biệt
  static void showError(
    BuildContext context, {
    required String message,
    ToastPosition position = ToastPosition.bottom,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
  }) {
    showToast(
      context,
      message: message,
      type: ToastType.error,
      position: position,
      duration: duration,
      onTap: onTap,
    );
  }

  /// Hiển thị toast success
  static void showSuccess(
    BuildContext context, {
    required String message,
    ToastPosition position = ToastPosition.bottom,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    showToast(
      context,
      message: message,
      type: ToastType.success,
      position: position,
      duration: duration,
      onTap: onTap,
    );
  }

  /// Hiển thị hiệu ứng cảm xúc bay
  static void showEmojiRain(
    BuildContext context, {
    List<String> emojis = const ['❤️', '😍', '👍', '🎉', '✨', '🔥', '💖'],
    Duration duration = const Duration(seconds: 3),
    int emojiCount = 15,
    double emojiSize = 30.0,
    VoidCallback? onComplete,
  }) {
    try {
      AnimatedEmojiOverlay.showEmojiRain(
        context,
        emojis: emojis,
        duration: duration,
        emojiCount: emojiCount,
        emojiSize: emojiSize,
        onComplete: onComplete,
      );
    } catch (e) {
      // Fallback: hiển thị toast thông báo nếu emoji animation fail
      showToast(
        context,
        message: 'Đã gửi tin nhắn!',
        type: ToastType.success,
      );
      onComplete?.call();
    }
  }

  /// Hiển thị loading overlay
  static OverlayEntry showLoading(
    BuildContext context, {
    String? message,
    bool barrierDismissible = false,
  }) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => LoadingWidget(
        message: message,
        barrierDismissible: barrierDismissible,
      ),
    );

    overlay.insert(overlayEntry);
    return overlayEntry;
  }

  /// Xóa toast hiện tại
  static void _dismissCurrentToast() {
    _currentToastEntry?.remove();
    _currentToastEntry = null;
  }

  /// Xóa overlay bằng entry
  static void dismissOverlay(OverlayEntry entry) {
    entry.remove();
  }
}
