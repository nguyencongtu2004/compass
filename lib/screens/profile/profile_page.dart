import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/location/location_bloc.dart';
import '../../constants/app_constants.dart';

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
        context.read<LocationBloc>().add(GetCurrentLocation());
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
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              Navigator.pop(context);
              context.go(AppConstants.loginRoute);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppConstants.primaryColor,
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.user.displayName ?? 'Người dùng',
                          style: AppConstants.titleStyle,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          state.user.email ?? '',
                          style: AppConstants.subtitleStyle,
                        ),
                      ],
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
                              applicationIcon: const Icon(
                                Icons.compass_calibration,
                                size: 48,
                                color: AppConstants.primaryColor,
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
                        color: AppConstants.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppConstants.successColor.withOpacity(0.3),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppConstants.successColor,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Vị trí của bạn đang được chia sẻ với bạn bè',
                              style: TextStyle(
                                color: AppConstants.successColor,
                              ),
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
                        backgroundColor: AppConstants.errorColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(
            child: Text('Không thể tải thông tin người dùng'),
          );
        },
      ),
    );
  }
}
