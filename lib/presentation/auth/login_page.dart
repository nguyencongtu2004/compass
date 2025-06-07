import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:minecraft_compass/presentation/core/widgets/common_scaffold.dart';
import 'package:minecraft_compass/utils/validator.dart';
import 'package:minecraft_compass/router/app_routes.dart';
import 'bloc/auth_bloc.dart';
import '../core/widgets/common_button.dart';
import '../core/widgets/common_textfield.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_spacing.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      _emailController.text = 'congtu2132004@gmail.com';
      _passwordController.text = '123456';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthLoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
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
            } else if (state is AuthAuthenticated) {
              // Đăng nhập thành công, chuyển đến splash để khởi tạo dữ liệu
              context.go(AppRoutes.splashRoute);
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
                      Icons.explore,
                      size: AppSpacing.iconXxl + AppSpacing.md,
                      color: AppColors.primary(context),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'CompassFriend',
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: AppColors.onBackground(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs2),
                    Text(
                      'Đăng nhập để bắt đầu',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.onSurfaceVariant(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg3),

                    // Email field
                    CommonTextField(
                      labelText: 'Email',
                      hintText: 'Nhập email của bạn',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: (value) => Validator.validateEmail(value),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Password field
                    CommonTextField(
                      labelText: 'Mật khẩu',
                      hintText: 'Nhập mật khẩu của bạn',
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
                    const SizedBox(height: AppSpacing.md),

                    // Login button
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return CommonButton(
                          text: 'Đăng nhập',
                          onPressed: _login,
                          isLoading: state is AuthLoading,
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Register link
                    TextButton(
                      onPressed: () => context.go(AppRoutes.registerRoute),
                      child: Text(
                        'Chưa có tài khoản? Đăng ký ngay',
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
