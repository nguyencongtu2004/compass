import 'package:flutter/material.dart';
import 'package:minecraft_compass/presentation/core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';

class MapFloatingActionButtons extends StatefulWidget {
  final VoidCallback onResetRotationPressed;
  final VoidCallback onMyLocationPressed;
  final bool isBottomWidgetExpanded;

  const MapFloatingActionButtons({
    super.key,
    required this.onResetRotationPressed,
    required this.onMyLocationPressed,
    this.isBottomWidgetExpanded = false,
  });

  @override
  State<MapFloatingActionButtons> createState() =>
      _MapFloatingActionButtonsState();
}

class _MapFloatingActionButtonsState extends State<MapFloatingActionButtons>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _positionAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _positionAnimation =
        Tween<double>(
          begin: 20, // Vị trí bình thường
          end: 140, // Vị trí khi friends list hiển thị
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOutCubic,
          ),
        );
  }

  @override
  void didUpdateWidget(MapFloatingActionButtons oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isBottomWidgetExpanded != oldWidget.isBottomWidgetExpanded) {
      if (widget.isBottomWidgetExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _positionAnimation,
      builder: (context, child) {
        return Positioned(
          bottom: _positionAnimation.value,
          right: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Button reset rotation về hướng Bắc
              // FloatingActionButton(
              //   mini: true,
              //   heroTag: "reset_rotation",
              //   backgroundColor: AppColors.secondary(context),
              //   foregroundColor: AppColors.onSecondary(context),
              //   elevation: 6,
              //   onPressed: widget.onResetRotationPressed,
              //   child: const Icon(Icons.explore, size: AppSpacing.iconMd),
              // ),
              // const SizedBox(height: 12),

              // Button về vị trí hiện tại
              FloatingActionButton(
                mini: true,
                heroTag: "my_location",
                backgroundColor: AppColors.primary(context),
                foregroundColor: AppColors.onPrimary(context),
                elevation: 6,
                onPressed: widget.onMyLocationPressed,
                child: const Icon(Icons.my_location, size: AppSpacing.iconMd),
              ),
            ],
          ),
        );
      },
    );
  }
}
