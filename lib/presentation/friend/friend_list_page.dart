import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:minecraft_compass/core/common/widgets/common_scaffold.dart';
import 'package:minecraft_compass/router/app_routes.dart';
import 'bloc/friend_bloc.dart';
import '../auth/bloc/auth_bloc.dart';
import '../../core/models/user_model.dart';
import '../../core/common/app_colors.dart';
import '../../core/common/app_text_styles.dart';
import '../../core/common/app_spacing.dart';
import '../../core/common/widgets/loading_indicator.dart';

class FriendListPage extends StatefulWidget {
  const FriendListPage({super.key});

  @override
  State<FriendListPage> createState() => _FriendListPageState();
}

class _FriendListPageState extends State<FriendListPage> {
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  void _loadFriends() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<FriendBloc>().add(LoadFriends(authState.user.uid));
    }
  }

  void _addFriend() {
    if (_emailController.text.trim().isEmpty) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<FriendBloc>().add(
        FindUserByEmail(_emailController.text.trim()),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      appBar: AppBar(
        title: const Text('Danh sách bạn bè'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => context.go(AppRoutes.friendRequestsRoute),
          ),
        ],
      ),
      body: Column(
        children: [
          // Add friend section
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            color: AppColors.surfaceVariant(context),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Nhập email để thêm bạn',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm2,
                        vertical: AppSpacing.xs2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs2),
                ElevatedButton(
                  onPressed: _addFriend,
                  child: const Text('Thêm'),
                ),
              ],
            ),
          ),

          // Friends list
          Expanded(
            child: BlocConsumer<FriendBloc, FriendState>(
              listener: (context, state) {
                if (state is FriendOperationFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error(context),
                    ),
                  );
                }
                if (state is UserSearchResult) {
                  if (state.user != null) {
                    _showAddFriendDialog(state.user!);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Không tìm thấy người dùng'),
                      ),
                    );
                  }
                }
                if (state is FriendRequestSent) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Đã gửi lời mời kết bạn'),
                      backgroundColor: AppColors.success(context),
                    ),
                  );
                  _emailController.clear();
                  _loadFriends();
                }
              },
              builder: (context, state) {
                if (state is FriendLoadInProgress) {
                  return const LoadingIndicator();
                }

                if (state is FriendLoadSuccess) {
                  if (state.friends.isEmpty) {
                    return Center(
                      child: Text(
                        'Chưa có bạn bè nào\nHãy thêm bạn bằng email',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.onSurfaceVariant(context),
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _loadFriends(),
                    child: ListView.builder(
                      itemCount: state.friends.length,
                      itemBuilder: (context, index) {
                        final friend = state.friends[index];
                        return _buildFriendTile(friend);
                      },
                    ),
                  );
                }

                return const Center(child: Text('Có lỗi xảy ra'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendTile(UserModel friend) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary(context),
        child: Text(
          friend.displayName.isNotEmpty
              ? friend.displayName[0].toUpperCase()
              : 'U',
          style: TextStyle(color: AppColors.onPrimary(context)),
        ),
      ),
      title: Text(friend.displayName),
      subtitle: Text(friend.email),
      trailing: PopupMenuButton(
        itemBuilder: (context) => [
          PopupMenuItem(
            child: const Row(
              children: [
                Icon(Icons.navigation),
                SizedBox(width: 8),
                Text('Xem la bàn'),
              ],
            ),
            onTap: () {
              if (friend.currentLocation != null) {
                context.go(
                  '${AppRoutes.compassRoute}?lat=${friend.currentLocation!.latitude}&lng=${friend.currentLocation!.longitude}',
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bạn này chưa chia sẻ vị trí')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showAddFriendDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm bạn'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tên: ${user.displayName}'),
            Text('Email: ${user.email}'),
            const SizedBox(height: 8),
            const Text('Bạn có muốn gửi lời mời kết bạn?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final authState = context.read<AuthBloc>().state;
              if (authState is AuthAuthenticated) {
                context.read<FriendBloc>().add(
                  SendFriendRequest(
                    fromUid: authState.user.uid,
                    toUid: user.uid,
                  ),
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Gửi lời mời'),
          ),
        ],
      ),
    );
  }
}
