import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minecraft_compass/core/common/widgets/common_scaffold.dart';
import 'package:minecraft_compass/core/common/widgets/keep_alive_wrapper.dart';
import 'package:minecraft_compass/presentation/location/compass_page.dart';
import '../auth/bloc/auth_bloc.dart';
import '../location/bloc/location_bloc.dart';
import '../profile/profile_page.dart';
import '../friend/friend_list_page.dart';

class HomePage extends StatefulWidget {
  final int initialPage;

  const HomePage({
    super.key,
    this.initialPage = 1, // Mặc định mở trang compass (giữa)
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPage);
    // Cập nhật vị trí ngay khi mở app
    _updateLocationOnStart();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
      return const CommonScaffold(
        body: Center(child: Text('Không thể tải trang chủ')),
      );
    }
    return CommonScaffold(
      body: PageView(
        controller: _pageController,
        children: [
          // Trang 0: Profile (trái)
          KeepAliveWrapper(child: const ProfilePage()),
          // Trang 1: Compass (giữa - mặc định)
          KeepAliveWrapper(
            child: CompassPage(targetLat: 21.851398, targetLng: 106.793197),
          ),
          // Trang 2: Friend List (phải)
          KeepAliveWrapper(child: const FriendListPage()),
        ],
      ),
    );
  }
}
