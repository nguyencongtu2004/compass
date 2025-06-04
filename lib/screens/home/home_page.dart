import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/friend/friend_bloc.dart';
import '../../blocs/location/location_bloc.dart';
import '../../constants/app_constants.dart';
import '../../repositories/friend_repository.dart';
import '../../repositories/location_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Cập nhật vị trí ngay khi mở app
    _updateLocationOnStart();
  }

  void _updateLocationOnStart() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      // Sử dụng event mới để lấy vị trí và cập nhật lên Firestore cùng lúc
      context.read<LocationBloc>().add(
        GetCurrentLocationAndUpdate(uid: authState.user.uid),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(
        body: Center(child: Text('Không thể tải trang chủ')),
      );
    }

    final user = authState.user;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => FriendBloc(friendRepository: FriendRepository()),
        ),
        BlocProvider(
          create: (context) =>
              LocationBloc(locationRepository: LocationRepository()),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chào mừng, ${user.displayName ?? user.email}'),
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AuthBloc>().add(const AuthLogoutRequested());
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildMenuCard(
                context,
                title: 'Danh sách bạn bè',
                icon: Icons.people,
                color: Colors.blue,
                onTap: () => context.go(AppConstants.friendListRoute),
              ),
              _buildMenuCard(
                context,
                title: 'Yêu cầu kết bạn',
                icon: Icons.person_add,
                color: Colors.green,
                onTap: () => context.go(AppConstants.friendRequestsRoute),
              ),
              _buildMenuCard(
                context,
                title: 'Thông tin cá nhân',
                icon: Icons.group_add,
                color: Colors.orange,
                onTap: () => context.go(AppConstants.profileRoute),
              ),
              _buildMenuCard(
                context,
                title: 'La bàn',
                icon: Icons.explore,
                color: Colors.red,
                onTap: () => _showCompassDialog(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.7), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCompassDialog(BuildContext context) {
    final latController = TextEditingController();
    final lngController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nhập tọa độ đích'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: latController,
              decoration: const InputDecoration(
                labelText: 'Vĩ độ (Latitude)',
                hintText: 'VD: 21.0285',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: lngController,
              decoration: const InputDecoration(
                labelText: 'Kinh độ (Longitude)',
                hintText: 'VD: 105.8542',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final lat = double.tryParse(latController.text.trim());
              final lng = double.tryParse(lngController.text.trim());

              if (lat != null && lng != null) {
                Navigator.pop(context);
                context.go('${AppConstants.compassRoute}?lat=$lat&lng=$lng');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng nhập tọa độ hợp lệ'),
                    backgroundColor: AppConstants.errorColor,
                  ),
                );
              }
            },
            child: const Text('Mở la bàn'),
          ),
        ],
      ),
    );
  }
}
