import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:minecraft_compass/router/app_routes.dart';
import '../auth/bloc/auth_bloc.dart';
import '../profile/bloc/profile_bloc.dart';
import '../friend/bloc/friend_bloc.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/widgets/common_scaffold.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _profileLoaded = false;
  bool _friendsLoaded = false;

  @override
  void initState() {
    super.initState();

    // Khởi tạo animation
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _controller.forward();

    // Khởi tạo dữ liệu
    _initializeData();
  }

  void _initializeData() {
    // Không làm gì ở đây, chỉ để AuthBloc tự động phát hiện trạng thái
    // và xử lý trong BlocListener bên dưới
  }

  void _checkAndNavigate() {
    if (_profileLoaded && _friendsLoaded) {
      // Cả hai đã tải xong, chuyển đến trang chính
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          context.go(AppRoutes.homeRoute);
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                // Đã đăng nhập, khởi tạo dữ liệu
                context.read<ProfileBloc>().add(const ProfileLoadRequested());
                context.read<FriendBloc>().add(
                  LoadFriendsAndRequests(state.user.uid),
                );
              } else if (state is AuthUnauthenticated) {
                // Chưa đăng nhập, chờ một chút để đảm bảo Firebase đã hoàn tất kiểm tra
                Future.delayed(const Duration(seconds: 1), () {
                  if (mounted) {
                    context.go(AppRoutes.loginRoute);
                  }
                });
              }
              // AuthInitial: không làm gì, chờ Firebase xác định trạng thái
            },
          ),
          BlocListener<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is ProfileLoaded || state is ProfileError) {
                setState(() => _profileLoaded = true);
                _checkAndNavigate();
              }
            },
          ),
          BlocListener<FriendBloc, FriendState>(
            listener: (context, state) {
              if (state is FriendAndRequestsLoadSuccess ||
                  state is FriendOperationFailure) {
                setState(() => _friendsLoaded = true);
                _checkAndNavigate();
              }
            },
          ),
        ],
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary(context),
                AppColors.primary(context).withOpacity(0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Logo và tên ứng dụng
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      children: [
                        // Icon la bàn
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(60),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.compass_calibration,
                            size: 60,
                            color: AppColors.primary(context),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Tên ứng dụng
                        Text(
                          'Minecraft Compass',
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Kết nối và định hướng với bạn bè',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // Loading indicator
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Đang khởi tạo...',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, authState) {
                          return BlocBuilder<ProfileBloc, ProfileState>(
                            builder: (context, profileState) {
                              return BlocBuilder<FriendBloc, FriendState>(
                                builder: (context, friendState) {
                                  String status = '';
                                  if (authState is AuthInitial) {
                                    status =
                                        'Đang kiểm tra trạng thái đăng nhập...';
                                  } else if (authState is AuthUnauthenticated) {
                                    status = 'Chuyển đến trang đăng nhập...';
                                  } else if (authState is AuthAuthenticated) {
                                    if (!_profileLoaded && !_friendsLoaded) {
                                      status =
                                          'Đang tải hồ sơ và danh sách bạn bè...';
                                    } else if (!_profileLoaded) {
                                      status = 'Đang tải hồ sơ...';
                                    } else if (!_friendsLoaded) {
                                      status = 'Đang tải danh sách bạn bè...';
                                    } else {
                                      status = 'Hoàn tất!';
                                    }
                                  }

                                  return Text(
                                    status,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                    textAlign: TextAlign.center,
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
