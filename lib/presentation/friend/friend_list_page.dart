import 'package:minecraft_compass/config/l10n/localization_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minecraft_compass/presentation/core/widgets/common_back_button.dart';
import 'package:minecraft_compass/presentation/core/widgets/widgets.dart';
import 'bloc/friend_bloc.dart';
import '../auth/bloc/auth_bloc.dart';
import '../../models/user_model.dart';
import '../core/theme/app_colors.dart';
import 'widgets/add_friend_section.dart';
import 'widgets/friends_list_view.dart';
import 'widgets/add_friend_dialog.dart';
import 'widgets/remove_friend_dialog.dart';

class FriendListPage extends StatefulWidget {
  const FriendListPage({super.key});

  @override
  State<FriendListPage> createState() => _FriendListPageState();
}

class _FriendListPageState extends State<FriendListPage> {
  final _emailController = TextEditingController();
  // Lưu trạng thái cuối cùng của danh sách bạn bè để tránh mất UI
  FriendAndRequestsLoadSuccess? _lastSuccessState;
  // Biến để track trạng thái đang tìm kiếm
  bool _isSearching = false;
  @override
  void initState() {
    super.initState();
    // Không cần load lại friends vì đã được khởi tạo trong splash screen
    // _loadFriends();
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
    return CommonScaffold(
      appBar: CommonAppbar(
        title: context.l10n.friendsList,
        leftWidget: CommonBackButton(),
      ),
      body: Column(
        children: [
          // Add friend section
          AddFriendSection(
            emailController: _emailController,
            isSearching: _isSearching,
            onAddFriend: _addFriend,
            onClear: () {
              context.read<FriendBloc>().add(const ClearSearchResults());
            },
          ),

          // Friends list
          Expanded(
            child: BlocConsumer<FriendBloc, FriendState>(
              listener: (context, state) {
                if (state is FriendOperationFailure) {
                  setState(() => _isSearching = false);

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
                      SnackBar(content: Text(context.l10n.userNotFound)),
                    );
                  }
                  context.read<FriendBloc>().add(const ClearSearchResults());
                }

                if (state is FriendRequestSent) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.friendRequestSent),
                      backgroundColor: AppColors.success(context),
                    ),
                  );
                  _emailController.clear();
                  // Clear search results and return to friends list
                  context.read<FriendBloc>().add(const ClearSearchResults());
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
                    return FriendsListView(
                      state: _lastSuccessState!,
                      onRemoveFriend: _showRemoveFriendDialog,
                      onAcceptRequest: _acceptRequest,
                      onDeclineRequest: _declineRequest,
                      onRefresh: _loadFriends,
                    );
                  }
                  return const LoadingIndicator();
                }

                if (state is FriendAndRequestsLoadSuccess) {
                  return FriendsListView(
                    state: state,
                    onRemoveFriend: _showRemoveFriendDialog,
                    onAcceptRequest: _acceptRequest,
                    onDeclineRequest: _declineRequest,
                    onRefresh: _loadFriends,
                  );
                }

                // Đối với các state khác (UserSearchResult, FriendRequestSent, etc.),
                // hiển thị UI cuối cùng thành công nếu có
                if (_lastSuccessState != null) {
                  return FriendsListView(
                    state: _lastSuccessState!,
                    onRemoveFriend: _showRemoveFriendDialog,
                    onAcceptRequest: _acceptRequest,
                    onDeclineRequest: _declineRequest,
                    onRefresh: _loadFriends,
                  );
                }

                return Center(child: Text(context.l10n.anErrorHasOccurred));
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddFriendDialog(UserModel user) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    // Kiểm tra nếu đó là chính mình
    if (user.uid == authState.user.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.youCannotAddYourselfAsAFriend)),
      );
      return;
    }

    // Kiểm tra nếu đã là bạn bè
    if (_lastSuccessState?.friends.any((friend) => friend.uid == user.uid) ==
        true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.displaynameIsNowYourFriend(user.displayName),
          ),
        ),
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
          content: Text(
            context.l10n.youHaveAFriendRequestFromDisplayname(user.displayName),
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AddFriendDialog(user: user),
    );
  }

  void _showRemoveFriendDialog(UserModel friend) {
    showDialog(
      context: context,
      builder: (context) => RemoveFriendDialog(friend: friend),
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
          content: Text(context.l10n.acceptedFriendRequest),
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
          content: Text(context.l10n.friendRequestDeclined),
          backgroundColor: AppColors.primary(context),
        ),
      );
    }
  }
}
