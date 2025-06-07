import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minecraft_compass/presentation/core/widgets/common_avatar.dart';
import 'bloc/friend_bloc.dart';
import '../auth/bloc/auth_bloc.dart';
import '../../models/user_model.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_spacing.dart';
import '../core/widgets/loading_indicator.dart';

class FriendListPage extends StatefulWidget {
  const FriendListPage({super.key});

  @override
  State<FriendListPage> createState() => _FriendListPageState();
}

class _FriendListPageState extends State<FriendListPage> {
  final _emailController = TextEditingController();

  // Lưu trạng thái cuối cùng của danh sách bạn bè để tránh mất UI
  FriendAndRequestsLoadSuccess? _lastSuccessState;
  // Biến để track trạng thái đang tìm kiếm và gửi lời mời
  bool _isSearching = false;
  bool _isSendingRequest = false;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  void _loadFriends() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<FriendBloc>().add(
        LoadFriendsAndRequests(authState.user.uid),
      );
    }
  }

  void _addFriend() {
    if (_emailController.text.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
    });

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
    return Column(
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
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
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
                onPressed: _isSearching ? null : _addFriend,
                child: _isSearching
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Thêm'),
              ),
            ],
          ),
        ),

        // Friends list
        Expanded(
          child: BlocConsumer<FriendBloc, FriendState>(
            listener: (context, state) {
              if (state is FriendOperationFailure) {
                setState(() {
                  _isSearching = false;
                  _isSendingRequest = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error(context),
                  ),
                );
              }

              if (state is UserSearchResult) {
                setState(() => _isSearching = false);

                if (state.user != null) {
                  _showAddFriendDialog(state.user!);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Không tìm thấy người dùng')),
                  );
                }
              }
              if (state is FriendRequestSent) {
                setState(() => _isSendingRequest = false);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Đã gửi lời mời kết bạn'),
                    backgroundColor: AppColors.success(context),
                  ),
                );
                _emailController.clear();
                // Reload để cập nhật danh sách bạn bè mới
                _loadFriends();
              }
              // Thêm xử lý cho các trường hợp khác
              if (state is FriendAndRequestsLoadSuccess) {
                // Lưu lại state thành công để sử dụng cho các state khác
                _lastSuccessState = state;
              }
            },
            builder: (context, state) {
              // Lưu lại state thành công cuối cùng
              if (state is FriendAndRequestsLoadSuccess) {
                _lastSuccessState = state;
              }

              if (state is FriendLoadInProgress) {
                // Nếu đang loading mà có state thành công trước đó, hiển thị state đó
                if (_lastSuccessState != null) {
                  return _buildFriendsList(_lastSuccessState!);
                }
                return const LoadingIndicator();
              }

              if (state is FriendAndRequestsLoadSuccess) {
                return _buildFriendsList(state);
              }

              // Đối với các state khác (UserSearchResult, FriendRequestSent, etc.),
              // hiển thị UI cuối cùng thành công nếu có
              if (_lastSuccessState != null) {
                return _buildFriendsList(_lastSuccessState!);
              }

              return const Center(child: Text('Có lỗi xảy ra'));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFriendsList(FriendAndRequestsLoadSuccess state) {
    return RefreshIndicator(
      onRefresh: () async => _loadFriends(),
      child: CustomScrollView(
        slivers: [
          // Friend requests section
          if (state.friendRequests.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                color: AppColors.primaryContainer(context),
                child: Text(
                  'Lời mời kết bạn (${state.friendRequests.length})',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.onPrimaryContainer(context),
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final request = state.friendRequests[index];
                return _buildFriendRequestTile(request);
              }, childCount: state.friendRequests.length),
            ),
            const SliverToBoxAdapter(child: Divider(height: 1)),
          ],

          // Friends section header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              color: AppColors.surfaceVariant(context),
              child: Text(
                state.friends.isEmpty
                    ? 'Chưa có bạn bè nào'
                    : 'Bạn bè (${state.friends.length})',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.onSurfaceVariant(context),
                ),
              ),
            ),
          ),

          // Friends list
          if (state.friends.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  'Chưa có bạn bè nào\nHãy thêm bạn bằng email',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.onSurfaceVariant(context),
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final friend = state.friends[index];
                return _buildFriendTile(friend);
              }, childCount: state.friends.length),
            ),
        ],
      ),
    );
  }

  Widget _buildFriendTile(UserModel friend) {
    return ListTile(
      leading: CommonAvatar(
        radius: 20,
        avatarUrl: friend.avatarUrl,
        displayName: friend.displayName,
      ),
      title: Text(friend.displayName),
      subtitle: Text(friend.email),
      trailing: IconButton(
        icon: Icon(Icons.close, color: AppColors.error(context), size: 20),
        onPressed: () => _showRemoveFriendDialog(friend),
        tooltip: 'Xóa bạn bè',
      ),
    );
  }

  Widget _buildFriendRequestTile(UserModel requester) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: ListTile(
        leading: CommonAvatar(
          radius: 20,
          avatarUrl: requester.avatarUrl,
          displayName: requester.displayName,
        ),
        title: Text(
          requester.displayName,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.onSurface(context),
          ),
        ),
        subtitle: Text(
          requester.email,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.onSurfaceVariant(context),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.check, color: AppColors.success(context)),
              onPressed: () => _acceptRequest(requester.uid),
              tooltip: 'Chấp nhận',
            ),
            IconButton(
              icon: Icon(Icons.close, color: AppColors.error(context)),
              onPressed: () => _declineRequest(requester.uid),
              tooltip: 'Từ chối',
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFriendDialog(UserModel user) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    // Kiểm tra nếu đó là chính mình
    if (user.uid == authState.user.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn không thể thêm chính mình làm bạn bè'),
        ),
      );
      return;
    }

    // Kiểm tra nếu đã là bạn bè
    if (_lastSuccessState?.friends.any((friend) => friend.uid == user.uid) ==
        true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${user.displayName} đã là bạn bè của bạn')),
      );
      return;
    }

    // Kiểm tra nếu đã gửi lời mời
    if (_lastSuccessState?.friendRequests.any(
          (request) => request.uid == user.uid,
        ) ==
        true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bạn đã có lời mời kết bạn từ ${user.displayName}'),
        ),
      );
      return;
    }

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
              setState(() {
                _isSendingRequest = true;
              });
              context.read<FriendBloc>().add(
                SendFriendRequest(fromUid: authState.user.uid, toUid: user.uid),
              );
              Navigator.pop(context);
            },
            child: _isSendingRequest
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Gửi lời mời'),
          ),
        ],
      ),
    );
  }

  void _acceptRequest(String requesterUid) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<FriendBloc>().add(
        AcceptFriendRequest(
          myUid: authState.user.uid,
          requesterUid: requesterUid,
        ),
      );
      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đã chấp nhận lời mời kết bạn'),
          backgroundColor: AppColors.success(context),
        ),
      );
    }
  }

  void _declineRequest(String requesterUid) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<FriendBloc>().add(
        DeclineFriendRequest(
          myUid: authState.user.uid,
          requesterUid: requesterUid,
        ),
      );
      // Hiển thị thông báo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đã từ chối lời mời kết bạn'),
          backgroundColor: AppColors.primary(context),
        ),
      );
    }
  }

  void _showRemoveFriendDialog(UserModel friend) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa bạn bè'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bạn có chắc chắn muốn xóa ${friend.displayName} khỏi danh sách bạn bè?',
            ),
            const SizedBox(height: 8),
            const Text(
              'Hành động này sẽ xóa bạn khỏi danh sách bạn bè của nhau.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error(context),
              foregroundColor: AppColors.onError(context),
            ),
            onPressed: () {
              Navigator.pop(context);
              _removeFriend(friend.uid);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _removeFriend(String friendUid) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<FriendBloc>().add(
        RemoveFriend(myUid: authState.user.uid, friendUid: friendUid),
      );
      // Hiển thị thông báo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đã xóa bạn bè'),
          backgroundColor: AppColors.primary(context),
        ),
      );
    }
  }
}
