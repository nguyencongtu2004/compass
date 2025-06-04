import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/friend/friend_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../models/user_model.dart';
import '../../constants/app_constants.dart';
import '../../widgets/loading_indicator.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách bạn bè'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => context.go(AppConstants.friendRequestsRoute),
          ),
        ],
      ),
      body: Column(
        children: [
          // Add friend section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      hintText: 'Nhập email để thêm bạn',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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
                      backgroundColor: AppConstants.errorColor,
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
                    const SnackBar(
                      content: Text('Đã gửi lời mời kết bạn'),
                      backgroundColor: AppConstants.successColor,
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
                    return const Center(
                      child: Text(
                        'Chưa có bạn bè nào\nHãy thêm bạn bằng email',
                        textAlign: TextAlign.center,
                        style: AppConstants.subtitleStyle,
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
        backgroundColor: AppConstants.primaryColor,
        child: Text(
          friend.displayName.isNotEmpty
              ? friend.displayName[0].toUpperCase()
              : 'U',
          style: const TextStyle(color: Colors.white),
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
                  '${AppConstants.compassRoute}?lat=${friend.currentLocation!.latitude}&lng=${friend.currentLocation!.longitude}',
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
