import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/friend/friend_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../models/user_model.dart';
import '../../constants/app_constants.dart';
import '../../widgets/loading_indicator.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lời mời kết bạn'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<FriendBloc, FriendState>(
        listener: (context, state) {
          if (state is FriendOperationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppConstants.errorColor,
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
              return const Center(
                child: Text(
                  'Không có lời mời kết bạn nào',
                  style: AppConstants.subtitleStyle,
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

          return const Center(child: Text('Có lỗi xảy ra'));
        },
      ),
    );
  }

  Widget _buildRequestTile(UserModel requester) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppConstants.primaryColor,
          child: Text(
            requester.displayName.isNotEmpty
                ? requester.displayName[0].toUpperCase()
                : 'U',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(requester.displayName),
        subtitle: Text(requester.email),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check, color: AppConstants.successColor),
              onPressed: () => _acceptRequest(requester.uid),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: AppConstants.errorColor),
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
