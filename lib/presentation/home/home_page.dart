import 'package:minecraft_compass/config/l10n/localization_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:minecraft_compass/presentation/compass/bloc/compass_bloc.dart';
import 'package:minecraft_compass/presentation/core/theme/app_spacing.dart';
import 'package:minecraft_compass/presentation/core/widgets/common_appbar.dart';
import 'package:minecraft_compass/presentation/core/widgets/common_avatar.dart';
import 'package:minecraft_compass/presentation/core/widgets/common_back_button.dart';
import 'package:minecraft_compass/presentation/core/widgets/common_scaffold.dart';
import 'package:minecraft_compass/presentation/core/widgets/keep_alive_wrapper.dart';
import 'package:minecraft_compass/presentation/map/map_page.dart';
import 'package:minecraft_compass/presentation/core/widgets/message_badge_icon.dart';
import 'package:minecraft_compass/presentation/messaging/conversation/conversation_list_page.dart';
import 'package:minecraft_compass/presentation/messaging/conversation/bloc/conversation_bloc.dart';
import 'package:minecraft_compass/presentation/profile/bloc/profile_bloc.dart';
import 'package:minecraft_compass/router/app_routes.dart';
import '../auth/bloc/auth_bloc.dart';
import '../profile/profile_page.dart';

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
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPage);

    // Chỉ cập nhật vị trí, không load lại toàn bộ dữ liệu vì đã được khởi tạo trong splash
    _updateLocationOnStart();
    _loadTotalUnreadCount();
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

  void _loadTotalUnreadCount() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      // Load unread message count
      context.read<ConversationBloc>().add(
        LoadTotalUnreadCount(authState.user.uid),
      );
    }
  }

  void _goToPage(int page) {
    if (page < 0 || page > 3) return; // Giới hạn trang từ 0 đến 3
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
      return Scaffold(
        body: Center(child: Text(context.l10n.unableToLoadTheHomePage)),
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
                title: context.l10n.profile,
                rightWidget: CommonBackButton(
                  isArrowRight: true,
                  onPressed: () => _goToPage(1),
                ),
              ),
              body: const ProfilePage(),
            ),
          ),

          // Trang 1: Bản đồ (giữa - mặc định)
          KeepAliveWrapper(
            child: CommonScaffold(
              isAppBarOverlay: true,
              resizeToAvoidBottomInset: false,
              appBar: CommonAppbar(
                title: context.l10n.map,
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
                rightWidget: MessageBadgeIcon(
                  icon: Icons.message,
                  size: AppSpacing.md4,
                  onTap: () => _goToPage(2),
                ),
              ),
              body: MapPage(
                // Chiều cao toolbar + status bar
                paddingTop: AppSpacing.toolBarHeight(context),
              ),
            ),
          ),

          // Trang 2: Messages (phải)
          KeepAliveWrapper(
            child: CommonScaffold(
              appBar: CommonAppbar(
                title: context.l10n.message,
                leftWidget: CommonBackButton(onPressed: () => _goToPage(1)),
                rightWidget: IconButton(
                  icon: const Icon(Icons.people),
                  onPressed: () => context.push(AppRoutes.friendListRoute),
                ),
              ),
              body: const ConversationListPage(),
            ),
          ),
        ],
      ),
    );
  }
}
