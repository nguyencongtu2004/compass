import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:minecraft_compass/presentation/core/theme/app_spacing.dart';
import 'package:minecraft_compass/presentation/core/widgets/common_avatar.dart';
import 'package:minecraft_compass/presentation/profile/bloc/profile_bloc.dart';
import 'package:minecraft_compass/router/app_routes.dart';
import 'package:minecraft_compass/utils/app_initialization.dart';
import '../auth/bloc/auth_bloc.dart';
import '../friend/bloc/friend_bloc.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLocationSharing = false;
  @override
  void initState() {
    super.initState();
    // Không cần load lại profile vì đã được khởi tạo trong splash screen
    // context.read<ProfileBloc>().add(const ProfileLoadRequested());
    _checkLocationPermission();
  }

  void _checkLocationPermission() {
    // Kiểm tra trạng thái chia sẻ vị trí
    // TODO: Implement location permission check
    setState(() {
      _isLocationSharing = true; // Tạm thời set true
    });
  }

  void _toggleLocationSharing(bool value) {
    setState(() {
      _isLocationSharing = value;
    });

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      if (value) {
        // Bật chia sẻ vị trí
        context.read<FriendBloc>().add(const GetCurrentLocation());
      } else {
        // Tắt chia sẻ vị trí
        // TODO: Implement stop location sharing
      }
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              // Reset user data first
              AppInitialization.resetUserData(context);
              // Then logout
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              Navigator.pop(context);
              context.go(AppRoutes.loginRoute);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error(context),
              foregroundColor: Colors.white,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  void _editProfile(BuildContext context, ProfileLoaded state) {
    final user = state.user;
    context.push(AppRoutes.editProfileRoute, extra: user);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProfileLoaded) {
          final user = state.user;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile header
                GestureDetector(
                  onTap: () => _editProfile(context, state),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary(context).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        CommonAvatar(
                          radius: 50,
                          avatarUrl: user.avatarUrl,
                          displayName: user.displayName,
                          backgroundColor: AppColors.primary(context),
                          fallbackIcon: Icons.person,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          user.displayName.isNotEmpty
                              ? user.displayName
                              : 'Người dùng',
                          style: AppTextStyles.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        if (user.username.isNotEmpty)
                          Text(
                            '@${user.username}',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.primary(context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Settings section
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.location_on),
                        title: const Text('Chia sẻ vị trí'),
                        subtitle: const Text(
                          'Cho phép bạn bè xem vị trí của bạn',
                        ),
                        trailing: Switch(
                          value: _isLocationSharing,
                          onChanged: _toggleLocationSharing,
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.compass_calibration),
                        title: const Text('Về la bàn'),
                        subtitle: const Text('Xem thông tin về ứng dụng'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: 'CompassFriend',
                            applicationVersion: '1.0.0',
                            applicationIcon: Icon(
                              Icons.compass_calibration,
                              size: 48,
                              color: AppColors.primaryLight,
                            ),
                            children: [
                              const Text(
                                'Ứng dụng la bàn kết nối với bạn bè, giúp bạn định hướng đến vị trí của người thân.',
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Location sharing info
                if (_isLocationSharing)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.success(context).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.success(
                          context,
                        ).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppColors.success(context),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Vị trí của bạn đang được chia sẻ với bạn bè',
                            style: TextStyle(color: AppColors.success(context)),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 32),

                // Logout button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Đăng xuất'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error(context),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (state is ProfileError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  state.message,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.error(context),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<ProfileBloc>().add(
                      const ProfileLoadRequested(),
                    );
                  },
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        return const Center(child: Text('Không thể tải thông tin người dùng'));
      },
    );
  }
}
