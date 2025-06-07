import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minecraft_compass/presentation/core/widgets/common_scaffold.dart';
import 'bloc/friend_bloc.dart';
import '../auth/bloc/auth_bloc.dart';
import '../../models/user_model.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_spacing.dart';
import '../core/widgets/loading_indicator.dart';

class FriendRequestPage extends StatefulWidget {
  const FriendRequestPage({super.key});

  @override
  State<FriendRequestPage> createState() => _FriendRequestPageState();
}

class _FriendRequestPageState extends State<FriendRequestPage> {
  @override
  void initState() {
    super.initState();
    _loadFriendRequests();
  }

  void _loadFriendRequests() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<FriendBloc>().add(LoadFriendRequests(authState.user.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      appBar: AppBar(
        title: Text(
          'Lời mời kết bạn',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.onPrimary(context),
          ),
        ),
        backgroundColor: AppColors.primary(context),
        foregroundColor: AppColors.onPrimary(context),
      ),
      body: BlocConsumer<FriendBloc, FriendState>(
        listener: (context, state) {
          if (state is FriendOperationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error(context),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is FriendLoadInProgress) {
            return const LoadingIndicator();
          }

          if (state is FriendRequestLoadSuccess) {
            if (state.requests.isEmpty) {
              return Center(
                child: Text(
                  'Không có lời mời kết bạn nào',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.onSurfaceVariant(context),
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => _loadFriendRequests(),
              child: ListView.builder(
                itemCount: state.requests.length,
                itemBuilder: (context, index) {
                  final requester = state.requests[index];
                  return _buildRequestTile(requester);
                },
              ),
            );
          }

          return Center(
            child: Text(
              'Có lỗi xảy ra',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.error(context),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequestTile(UserModel requester) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary(context),
          child: Text(
            requester.displayName.isNotEmpty
                ? requester.displayName[0].toUpperCase()
                : 'U',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.onPrimary(context),
            ),
          ),
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
            ),
            IconButton(
              icon: Icon(Icons.close, color: AppColors.error(context)),
              onPressed: () => _declineRequest(requester.uid),
            ),
          ],
        ),
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
    }
  }
}
