import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minecraft_compass/presentation/compass/bloc/compass_bloc.dart';
import 'package:minecraft_compass/presentation/core/theme/app_spacing.dart';
import 'package:minecraft_compass/presentation/core/widgets/common_appbar.dart';
import 'package:minecraft_compass/presentation/core/widgets/common_avatar.dart';
import 'package:minecraft_compass/presentation/core/widgets/common_scaffold.dart';
import 'package:minecraft_compass/presentation/core/widgets/keep_alive_wrapper.dart';
import 'package:minecraft_compass/presentation/map/map_page.dart';
import 'package:minecraft_compass/presentation/newfeed/newfeed_page.dart';
import 'package:minecraft_compass/presentation/profile/bloc/profile_bloc.dart';
import '../auth/bloc/auth_bloc.dart';
import '../profile/profile_page.dart';
import '../friend/friend_list_page.dart';

class HomePage extends StatefulWidget {
  final int initialPage;
  final Map<String, String>? queryParams;

  const HomePage({
    super.key,
    this.initialPage = 1, // Mặc định mở trang compass (giữa)
    this.queryParams,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _pageController;
  late PageController _midPageController;
  String page1Title = 'Bản đồ';
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPage);
    _midPageController = PageController(initialPage: 0);
    _midPageController.addListener(() {
      // Cập nhật tiêu đề khi cuộn trang giữa
      if (_midPageController.page == 0) {
        page1Title = 'Bản đồ';
      } else if (_midPageController.page == 1) {
        page1Title = 'Bản tin';
      }
      setState(() {});
    });

    // Chỉ cập nhật vị trí, không load lại toàn bộ dữ liệu vì đã được khởi tạo trong splash
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
      context.read<CompassBloc>().add(
        GetCurrentLocationAndUpdate(uid: authState.user.uid),
      );
    }
  }

  void _goToPage(int page) {
    if (page < 0 || page > 2) return; // Giới hạn trang từ 0 đến 2
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(
        body: Center(child: Text('Không thể tải trang chủ')),
      );
    }
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          // Trang 0: Profile (trái)
          KeepAliveWrapper(
            child: CommonScaffold(
              appBar: CommonAppbar(
                title: 'Hồ sơ',
                rightWidget: GestureDetector(
                  onTap: () => _goToPage(1),
                  child: const Icon(Icons.arrow_forward, size: AppSpacing.md4),
                ),
              ),
              body: const ProfilePage(),
            ),
          ),

          // Trang 1: Compass (giữa - mặc định)
          KeepAliveWrapper(
            child: CommonScaffold(
              isAppBarOverlay: true,
              appBar: CommonAppbar(
                title: page1Title,
                isBackgroudTransparentGradient: true,
                leftWidget: GestureDetector(
                  onTap: () => _goToPage(0),
                  child: BlocBuilder<ProfileBloc, ProfileState>(
                    builder: (context, state) {
                      if (state is ProfileLoaded) {
                        return CommonAvatar(
                          radius: AppSpacing.md2,
                          avatarUrl: state.user.avatarUrl,
                          displayName: state.user.displayName,
                        );
                      }
                      return CommonAvatar(radius: AppSpacing.md2);
                    },
                  ),
                ),
                rightWidget: GestureDetector(
                  onTap: () => _goToPage(2),
                  child: const Icon(Icons.people_alt, size: AppSpacing.md4),
                ),
              ),
              body: PageView(
                controller: _midPageController,
                scrollDirection: Axis.vertical,
                children: [
                  MapPage(
                    // Chiều cao toolbar + status bar
                    paddingTop: AppSpacing.toolBarHeight(context),
                    onBackPressed: () {
                      // Quay lại trang la bàn
                      _midPageController.animateToPage(
                        1,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOutCubic,
                      );
                    },
                  ),
                  KeepAliveWrapper(
                    child: NewFeedPage(
                      paddingTop: AppSpacing.toolBarHeight(context),
                    ),
                  ),
                  // KeepAliveWrapper(
                  //   child: CompassPage(
                  //     targetLat: double.tryParse(
                  //       widget.queryParams?['lat'] ?? '',
                  //     ),
                  //     targetLng: double.tryParse(
                  //       widget.queryParams?['lng'] ?? '',
                  //     ),
                  //     friendName: widget.queryParams?['friendName'],
                  //   ),
                  // ),
                ],
              ),
            ),
          ),

          // Trang 2: Friend List (phải)
          KeepAliveWrapper(
            child: CommonScaffold(
              appBar: CommonAppbar(
                title: 'Bạn bè',
                leftWidget: GestureDetector(
                  onTap: () => _goToPage(1),
                  child: const Icon(Icons.arrow_back, size: AppSpacing.md4),
                ),
              ),
              body: const FriendListPage(),
            ),
          ),
        ],
      ),
    );
  }
}
