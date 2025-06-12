import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:minecraft_compass/router/app_routes.dart';
import 'package:minecraft_compass/utils/app_initialization.dart';
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
  bool _hasNavigated = false;
  bool _hasInitialized = false;
  Timer? _timeoutTimer;

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

    // Reset states và khởi tạo dữ liệu
    _initializeData();

    // Timeout để tránh bị treo mãi mãi
    _timeoutTimer = Timer(const Duration(seconds: 10), () {
      if (!_hasNavigated && mounted) {
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticated) {
          _navigateToHome();
        } else {
          _navigateToLogin();
        }
      }
    });
  }

  void _initializeData() {
    // Reset states để xử lý hot reload
    _profileLoaded = false;
    _friendsLoaded = false;
    _hasNavigated = false;
    _hasInitialized = false;

    debugPrint(
      'SplashPage: _initializeData called - performing hot reload reset',
    );

    // Kiểm tra trạng thái hiện tại và xử lý accordingly
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      debugPrint('SplashPage: AuthState is ${authState.runtimeType}');

      if (authState is AuthAuthenticated && !_hasInitialized) {
        _hasInitialized = true;

        // Kiểm tra trạng thái hiện tại của các BLoC để xử lý hot reload
        final profileState = context.read<ProfileBloc>().state;
        final friendState = context.read<FriendBloc>().state;

        debugPrint('SplashPage: ProfileState is ${profileState.runtimeType}');
        debugPrint('SplashPage: FriendState is ${friendState.runtimeType}');

        // Nếu data đã được load rồi, đánh dấu là đã loaded
        if (profileState is ProfileLoaded || profileState is ProfileError) {
          _profileLoaded = true;
          debugPrint('SplashPage: Profile already loaded, marking as loaded');
        }
        if (friendState is FriendAndRequestsLoadSuccess ||
            friendState is FriendOperationFailure) {
          _friendsLoaded = true;
          debugPrint('SplashPage: Friends already loaded, marking as loaded');
        }

        // Nếu chưa loaded thì khởi tạo, nếu đã loaded thì kiểm tra navigate
        if (!_profileLoaded || !_friendsLoaded) {
          debugPrint('SplashPage: Initializing user data...');
          AppInitialization.initializeUserData(context, authState.user);
        } else {
          debugPrint(
            'SplashPage: All data already loaded, checking navigation...',
          );
          _checkAndNavigate();
        }
      } else if (authState is AuthUnauthenticated && !_hasNavigated) {
        debugPrint('SplashPage: User not authenticated, navigating to login');
        _navigateToLogin();
      }
    });
  }

  void _navigateToHome() {
    if (!_hasNavigated && mounted) {
      _hasNavigated = true;
      _timeoutTimer?.cancel();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          context.go(AppRoutes.homeRoute);
        }
      });
    }
  }

  void _navigateToLogin() {
    if (!_hasNavigated && mounted) {
      _hasNavigated = true;
      _timeoutTimer?.cancel();
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          context.go(AppRoutes.loginRoute);
        }
      });
    }
  }

  void _checkAndNavigate() {
    debugPrint(
      'SplashPage: _checkAndNavigate called - Profile: $_profileLoaded, Friends: $_friendsLoaded, HasNavigated: $_hasNavigated',
    );
    if (_profileLoaded && _friendsLoaded && !_hasNavigated) {
      _navigateToHome();
    }
  }
  @override
  void dispose() {
    _controller.dispose();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated && !_hasInitialized) {
                // Đã đăng nhập khi mở app, khởi tạo dữ liệu
                _hasInitialized = true;

                // Kiểm tra trạng thái hiện tại của các BLoC để xử lý hot reload
                final profileState = context.read<ProfileBloc>().state;
                final friendState = context.read<FriendBloc>().state;

                // Nếu data đã được load rồi, đánh dấu là đã loaded
                if (profileState is ProfileLoaded ||
                    profileState is ProfileError) {
                  _profileLoaded = true;
                }
                if (friendState is FriendAndRequestsLoadSuccess ||
                    friendState is FriendOperationFailure) {
                  _friendsLoaded = true;
                }

                // Nếu chưa loaded thì khởi tạo, nếu đã loaded thì kiểm tra navigate
                if (!_profileLoaded || !_friendsLoaded) {
                  AppInitialization.initializeUserData(context, state.user);
                } else {
                  _checkAndNavigate();
                }
              } else if (state is AuthUnauthenticated) {
                // Chưa đăng nhập
                _navigateToLogin();
              }
              // AuthInitial: không làm gì, chờ Firebase xác định trạng thái
            },
          ),
          BlocListener<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is ProfileLoaded || state is ProfileError) {
                if (!_profileLoaded) {
                  setState(() => _profileLoaded = true);
                  _checkAndNavigate();
                }
              }
            },
          ),
          BlocListener<FriendBloc, FriendState>(
            listener: (context, state) {
              if (state is FriendAndRequestsLoadSuccess ||
                  state is FriendOperationFailure) {
                if (!_friendsLoaded) {
                  setState(() => _friendsLoaded = true);
                  _checkAndNavigate();
                }
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
                AppColors.primary(context).withValues(alpha: 0.8),
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
                                color: Colors.black.withValues(alpha: 0.2),
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
                            color: Colors.white.withValues(alpha: 0.9),
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
                          color: Colors.white.withValues(alpha: 0.8),
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
                                      color: Colors.white.withValues(
                                        alpha: 0.7,
                                      ),
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
