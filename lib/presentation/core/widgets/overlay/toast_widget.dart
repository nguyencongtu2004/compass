import 'package:flutter/material.dart';
import 'package:minecraft_compass/presentation/core/theme/app_colors.dart';
import 'package:minecraft_compass/presentation/core/theme/app_spacing.dart';
import 'package:minecraft_compass/presentation/core/widgets/overlay/toast_types.dart';

/// Widget hiển thị toast notification với animation đẹp
class ToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final ToastPosition position;
  final Duration duration;
  final String? customIcon;
  final Color? customColor;
  final VoidCallback? onTap;
  final VoidCallback onDismiss;

  const ToastWidget({
    super.key,
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
  State<ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Animation controller đơn giản
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Slide animation đơn giản
    _slideAnimation = Tween<double>(
      begin: widget.position == ToastPosition.top ? -1.0 : 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();

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
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              0,
              _slideAnimation.value * 100,
            ),
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: () {
                  widget.onTap?.call();
                  _dismiss();
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
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
                        child: Icon(_getIcon(), color: Colors.white, size: 20),
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
