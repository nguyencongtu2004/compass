import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:minecraft_compass/core/common/widgets/common_scaffold.dart';
import 'package:minecraft_compass/core/utils/validator.dart';
import 'package:minecraft_compass/router/app_routes.dart';
import 'bloc/auth_bloc.dart';
import '../../core/common/widgets/common_button.dart';
import '../../core/common/widgets/common_textfield.dart';
import '../../core/common/app_colors.dart';
import '../../core/common/app_text_styles.dart';
import '../../core/common/app_spacing.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthRegisterRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _displayNameController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.onBackground(context)),
          onPressed: () => context.go(AppRoutes.loginRoute),
        ),
      ),
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error(context),
                ),
              );
            }
          },
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md3),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo/Title
                    Icon(
                      Icons.person_add,
                      size: AppSpacing.iconXxl + AppSpacing.md,
                      color: AppColors.primary(context),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Tạo tài khoản',
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: AppColors.onBackground(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs2),
                    Text(
                      'Điền thông tin để đăng ký',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.onSurfaceVariant(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg3),

                    // Display Name field
                    CommonTextField(
                      labelText: 'Tên hiển thị',
                      hintText: 'Nhập tên hiển thị của bạn',
                      controller: _displayNameController,
                      prefixIcon: Icons.person_outlined,
                      validator: (value) =>
                          Validator.validateDisplayName(value),
                    ),
                    const SizedBox(height: 16),

                    // Email field
                    CommonTextField(
                      labelText: 'Email',
                      hintText: 'Nhập email của bạn',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: (value) => Validator.validateEmail(value),
                    ),
                    const SizedBox(height: 16),

                    // Password field
                    CommonTextField(
                      labelText: 'Mật khẩu',
                      hintText: 'Nhập mật khẩu (ít nhất 6 ký tự)',
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      prefixIcon: Icons.lock_outlined,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                      validator: (value) => Validator.validatePassword(value),
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password field
                    CommonTextField(
                      labelText: 'Xác nhận mật khẩu',
                      hintText: 'Nhập lại mật khẩu',
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      prefixIcon: Icons.lock_outlined,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng xác nhận mật khẩu';
                        }
                        if (value != _passwordController.text) {
                          return 'Mật khẩu xác nhận không khớp';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md4),

                    // Register button
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return CommonButton(
                          text: 'Đăng ký',
                          onPressed: _register,
                          isLoading: state is AuthLoading,
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Login link
                    TextButton(
                      onPressed: () => context.go(AppRoutes.loginRoute),
                      child: Text(
                        'Đã có tài khoản? Đăng nhập ngay',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.primary(context),
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
  }
}
