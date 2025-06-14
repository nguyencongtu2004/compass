import 'package:flutter/material.dart';
import 'package:minecraft_compass/presentation/core/theme/app_colors.dart';
import 'package:minecraft_compass/presentation/core/theme/app_spacing.dart';
import 'package:minecraft_compass/presentation/core/widgets/overlay/animated_emoji_overlay.dart';

/// Enum cho các loại toast
enum ToastType { success, error, warning, info, custom }

/// Enum cho vị trí hiển thị toast
enum ToastPosition { top, center, bottom }

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
      builder: (context) => _ToastWidget(
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
      builder: (context) => _LoadingWidget(
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

/// Widget hiển thị toast
class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final ToastPosition position;
  final Duration duration;
  final String? customIcon;
  final Color? customColor;
  final VoidCallback? onTap;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.position,
    required this.duration,
    this.customIcon,
    this.customColor,
    this.onTap,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _shakeController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Animation controller chính
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Animation controller cho shake effect (dành cho error)
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Slide animation với curve mượt hơn
    _slideAnimation = Tween<double>(
      begin: widget.position == ToastPosition.top ? -1.0 : 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Scale animation cho hiệu ứng bounce
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    // Shake animation cho error toast
    _shakeAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticInOut),
    );

    _controller.forward();

    // Nếu là error toast, thêm shake effect
    if (widget.type == ToastType.error) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          _shakeController.repeat(reverse: true);
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              _shakeController.stop();
            }
          });
        }
      });
    }

    // Auto dismiss
    Future.delayed(widget.duration, _dismiss);
  }

  void _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _controller.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: AppSpacing.md,
      right: AppSpacing.md,
      top: widget.position == ToastPosition.top
          ? AppSpacing.toolBarHeight(context) + AppSpacing.md
          : null,
      bottom: widget.position == ToastPosition.bottom
          ? AppSpacing.xl + MediaQuery.of(context).viewInsets.bottom
          : null,
      child: AnimatedBuilder(
        animation: Listenable.merge([_controller, _shakeController]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              widget.type == ToastType.error ? _shakeAnimation.value * 3 : 0,
              _slideAnimation.value * 100,
            ),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Material(
                  color: Colors.transparent,
                  child: GestureDetector(
                    onTap: () {
                      widget.onTap?.call();
                      _dismiss();
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                      ),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        gradient: _getBackgroundGradient(context),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _getShadowColor(context),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.1),
                            blurRadius: 1,
                            offset: const Offset(0, 1),
                            spreadRadius: 0,
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Icon container với background tròn
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getIcon(),
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          // Message text
                          Expanded(
                            child: Text(
                              widget.message,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          // Close button
                          GestureDetector(
                            onTap: _dismiss,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Tạo gradient background hiện đại
  LinearGradient _getBackgroundGradient(BuildContext context) {
    switch (widget.type) {
      case ToastType.success:
        return LinearGradient(
          colors: [const Color(0xFF4CAF50), const Color(0xFF45A049)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ToastType.error:
        return LinearGradient(
          colors: [const Color(0xFFE53E3E), const Color(0xFFD53F3F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ToastType.warning:
        return LinearGradient(
          colors: [const Color(0xFFFF9800), const Color(0xFFF57C00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ToastType.info:
        return LinearGradient(
          colors: [const Color(0xFF2196F3), const Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ToastType.custom:
        if (widget.customColor != null) {
          return LinearGradient(
            colors: [
              widget.customColor!,
              widget.customColor!.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
        }
        return LinearGradient(
          colors: [
            AppColors.primary(context),
            AppColors.primary(context).withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  /// Tạo shadow color phù hợp
  Color _getShadowColor(BuildContext context) {
    switch (widget.type) {
      case ToastType.success:
        return const Color(0xFF4CAF50).withValues(alpha: 0.3);
      case ToastType.error:
        return const Color(0xFFE53E3E).withValues(alpha: 0.3);
      case ToastType.warning:
        return const Color(0xFFFF9800).withValues(alpha: 0.3);
      case ToastType.info:
        return const Color(0xFF2196F3).withValues(alpha: 0.3);
      case ToastType.custom:
        return (widget.customColor ?? AppColors.primary(context)).withValues(
          alpha: 0.3,
        );
    }
  }

  IconData _getIcon() {
    if (widget.customIcon != null) {
      return Icons.info; // Default fallback
    }

    switch (widget.type) {
      case ToastType.success:
        return Icons.check_circle_rounded;
      case ToastType.error:
        return Icons.error_rounded;
      case ToastType.warning:
        return Icons.warning_rounded;
      case ToastType.info:
        return Icons.info_rounded;
      case ToastType.custom:
        return Icons.info_rounded;
    }
  }
}

/// Widget hiển thị loading
class _LoadingWidget extends StatelessWidget {
  final String? message;
  final bool barrierDismissible;

  const _LoadingWidget({this.message, required this.barrierDismissible});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.5),
      child: GestureDetector(
        onTap: barrierDismissible ? () => Navigator.of(context).pop() : null,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: AppColors.primary(context),
                  strokeWidth: 3,
                ),
                if (message != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    message!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurface(context),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
