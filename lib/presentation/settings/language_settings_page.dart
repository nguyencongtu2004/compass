import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minecraft_compass/config/l10n/localization_extensions.dart';
import 'package:minecraft_compass/presentation/core/widgets/common_scaffold.dart';
import 'package:minecraft_compass/presentation/core/widgets/common_appbar.dart';
import 'package:minecraft_compass/presentation/core/widgets/common_back_button.dart';
import 'package:minecraft_compass/presentation/core/theme/app_colors.dart';
import 'package:minecraft_compass/presentation/core/theme/app_text_styles.dart';
import 'package:minecraft_compass/presentation/core/theme/app_spacing.dart';
import 'package:minecraft_compass/presentation/locale/bloc/locale_bloc.dart';

/// Example Settings Page with Language Selection
/// Đây là ví dụ về cách sử dụng LocaleBloc trong settings
class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      appBar: CommonAppbar(
        title: 'Language / Ngôn ngữ',
        leftWidget: const CommonBackButton(),
      ),
      body: BlocBuilder<LocaleBloc, LocaleState>(
        builder: (context, state) {
          Locale currentLocale = const Locale('en', 'US');

          if (state is LocaleLoaded) {
            currentLocale = state.locale;
          }

          return Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // English Option
                _LanguageOption(
                  title: 'English',
                  subtitle: 'English (United States)',
                  locale: const Locale('en', 'US'),
                  currentLocale: currentLocale,
                  onTap: () {
                    context.read<LocaleBloc>().add(
                      const LocaleChanged(Locale('en', 'US')),
                    );
                  },
                ),

                const SizedBox(height: AppSpacing.sm),

                // Vietnamese Option
                _LanguageOption(
                  title: 'Tiếng Việt',
                  subtitle: 'Vietnamese (Vietnam)',
                  locale: const Locale('vi', 'VN'),
                  currentLocale: currentLocale,
                  onTap: () {
                    context.read<LocaleBloc>().add(
                      const LocaleChanged(Locale('vi', 'VN')),
                    );
                  },
                ),

                const SizedBox(height: AppSpacing.xl),

                // Info Box
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant(context),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primary(context),
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          context.l10n.appWillRestart,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.onSurface(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final Locale locale;
  final Locale currentLocale;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.title,
    required this.subtitle,
    required this.locale,
    required this.currentLocale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = locale.languageCode == currentLocale.languageCode;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? AppColors.primary(context)
                : AppColors.outline(context),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          color: isSelected
              ? AppColors.primary(context).withOpacity(0.05)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.onSurface(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant(context),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary(context),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
