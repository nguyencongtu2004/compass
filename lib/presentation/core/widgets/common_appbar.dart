import 'package:flutter/material.dart';
import 'package:minecraft_compass/presentation/core/theme/app_colors.dart';
import 'package:minecraft_compass/presentation/core/theme/app_spacing.dart';
import 'package:minecraft_compass/presentation/core/theme/app_text_styles.dart';

class CommonAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? leftWidget;
  final Widget? rightWidget;
  final Widget? customWidget;
  final bool isBackgroudTransparentGradient;

  const CommonAppbar({
    super.key,
    this.title,
    this.leftWidget,
    this.rightWidget,
    this.customWidget,
    this.isBackgroudTransparentGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: isBackgroudTransparentGradient
            ? const LinearGradient(
                colors: [Colors.black87, Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : null,
        color: isBackgroudTransparentGradient
            ? null
            : AppColors.surface(context),
      ),
      child: SafeArea(
        bottom: false,
        child:
            customWidget ??
            Row(
              spacing: AppSpacing.sm,
              children: [
                // Left widget area - always present to keep title centered
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.md),
                  child: SizedBox(
                    width: AppSpacing.lg2,
                    height: AppSpacing.lg2,
                    child: leftWidget ?? const SizedBox(),
                  ),
                ),

                // Title area - expanded to fill remaining space
                if (title != null)
                  Expanded(
                    child: Center(
                      child: Text(title!, style: AppTextStyles.titleLarge),
                    ),
                  ),

                // Right widget area - always present to keep title centered
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
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
