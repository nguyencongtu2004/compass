import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minecraft_compass/models/user_model.dart';
import 'package:minecraft_compass/presentation/map/bloc/map_bloc.dart';
import 'package:minecraft_compass/presentation/map/widgets/bottom_button/friend_list.dart';
import 'package:minecraft_compass/presentation/map/widgets/map_toggle_switch.dart';
import 'map_create_post_button.dart';

class MapBottomActionWidget extends StatefulWidget {
  const MapBottomActionWidget({super.key, this.onFriendTap});

  final void Function(UserModel)? onFriendTap;

  @override
  State<MapBottomActionWidget> createState() => _MapBottomActionWidgetState();
}

class _MapBottomActionWidgetState extends State<MapBottomActionWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _createPostSlideAnimation;
  late Animation<Offset> _friendsListSlideAnimation;

  @override
  void initState() {
    super.initState();

    // Khởi tạo animation controller
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Animation cho nút tạo bài (kéo xuống)
    _createPostSlideAnimation =
        Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0, 1.5), // Kéo xuống dưới
        ).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: Curves.easeInOutCubic,
          ),
        );

    // Animation cho danh sách bạn bè (kéo từ dưới lên)
    _friendsListSlideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 1.5), // Bắt đầu từ dưới
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _slideController,
            curve: Curves.easeInOutCubic,
          ),
        );
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MapBloc, MapState>(
      listener: (context, state) {
        if (state is MapReady) {
          // Trigger animation dựa trên mode hiện tại
          if (state.currentMode == MapDisplayMode.locations) {
            // Chuyển sang locations mode - hiển thị danh sách bạn bè
            _slideController.forward();
          } else {
            // Chuyển sang friends/explore mode - hiển thị nút tạo bài
            _slideController.reverse();
          }
        }
      },
      child: BlocBuilder<MapBloc, MapState>(
        builder: (context, mapState) {
          if (mapState is! MapReady) {
            return const SizedBox.shrink();
          }

          return Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 120, // Chiều cao cố định để tránh jump
              child: Stack(
                children: [
                  // Nút tạo bài đăng
                  SlideTransition(
                    position: _createPostSlideAnimation,
                    child: const Center(child: MapCreatePostButton()),
                  ),

                  // Danh sách bạn bè
                  SlideTransition(
                    position: _friendsListSlideAnimation,
                    child: FriendList(
                      friends: mapState.friends,
                      onFriendSelected: widget.onFriendTap,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
