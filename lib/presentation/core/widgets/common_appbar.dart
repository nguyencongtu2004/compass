import 'package:flutter/material.dart';
import 'package:minecraft_compass/presentation/core/theme/app_spacing.dart';
import 'package:minecraft_compass/presentation/core/theme/app_text_styles.dart';

class CommonAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leftWidget;
  final Widget? rightWidget;

  const CommonAppbar({
    super.key,
    required this.title,
    this.leftWidget,
    this.rightWidget,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        spacing: AppSpacing.sm,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.md),
            child: SizedBox(
              width: AppSpacing.lg2,
              height: AppSpacing.lg2,
              child: leftWidget ?? const SizedBox(),
            ),
          ),

          Expanded(
            child: Center(child: Text(title, style: AppTextStyles.titleLarge)),
          ),

          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: SizedBox(
              width: AppSpacing.lg2,
              height: AppSpacing.lg2,
              child: rightWidget ?? const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
