import 'package:minecraft_compass/config/l10n/localization_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minecraft_compass/presentation/auth/bloc/auth_bloc.dart';
import 'package:minecraft_compass/presentation/core/theme/app_colors.dart';
import 'package:minecraft_compass/presentation/core/theme/app_spacing.dart';
import 'package:minecraft_compass/presentation/core/widgets/common_textfield.dart';
import 'package:minecraft_compass/utils/validator.dart';

class ForgotPasswordDialog extends StatelessWidget {
  ForgotPasswordDialog({super.key});

  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.forgotPassword),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.l10n.enterYourEmailAddressToReceiveAPasswordResetLink),
          const SizedBox(height: AppSpacing.md),
          CommonTextField(
            controller: emailController,
            labelText: context.l10n.email,
            hintText: context.l10n.enterYourEmail,
            keyboardType: TextInputType.emailAddress,
            validator: (value) => Validator.validateEmail(value, context),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
        BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthPasswordResetSent) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    context.l10n.aPasswordResetEmailHasBeenSentToEmail(
                      state.email,
                    ),
                  ),
                  backgroundColor: AppColors.primary(context),
                ),
              );
            } else if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error(context),
                ),
              );
            }
          },
          builder: (context, state) {
            return TextButton(
              onPressed: state is AuthLoading
                  ? null
                  : () {
                      if (emailController.text.trim().isNotEmpty &&
                          Validator.validateEmail(
                                emailController.text.trim(),
                                context,
                              ) ==
                              null) {
                        context.read<AuthBloc>().add(
                          AuthPasswordResetRequested(
                            email: emailController.text.trim(),
                          ),
                        );
                      }
                    },
              child: state is AuthLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(context.l10n.send),
            );
          },
        ),
      ],
    );
  }
}
