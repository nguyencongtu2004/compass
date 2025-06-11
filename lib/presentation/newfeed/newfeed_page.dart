import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minecraft_compass/presentation/core/widgets/common_scaffold.dart';
import '../../models/newsfeed_post_model.dart';
import '../auth/bloc/auth_bloc.dart';
import '../friend/bloc/friend_bloc.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import 'bloc/newsfeed_bloc.dart';
import 'widgets/create_post_dialog.dart';
import 'widgets/post_card.dart';

class NewFeedPage extends StatefulWidget {
  final double paddingTop;

  const NewFeedPage({super.key, this.paddingTop = 0.0});

  @override
  State<NewFeedPage> createState() => _NewFeedPageState();
}

class _NewFeedPageState extends State<NewFeedPage> {
  @override
  void initState() {
    super.initState();
    // Load posts for Feed mode (mình + bạn bè)
    _loadFeedPosts();
  }

  void _loadFeedPosts() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final currentUserId = authState.user.uid;

      // Lấy danh sách bạn bè
      final friendState = context.read<FriendBloc>().state;
      List<String> friendUids = [];
      if (friendState is FriendAndRequestsLoadSuccess) {
        friendUids = friendState.friends.map((friend) => friend.uid).toList();
      }

      context.read<NewsfeedBloc>().add(
        LoadFriendPosts(currentUserId: currentUserId, friendUids: friendUids),
      );
    } else {
      // Fallback nếu chưa authenticated
      context.read<NewsfeedBloc>().add(const LoadPosts());
    }
  }

  void _showCreatePostDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CreatePostDialog(
        onCreatePost: (imageFile, caption, location) async {
          context.read<NewsfeedBloc>().add(
            CreatePost(
              imageFile: imageFile,
              caption: caption,
              location: location,
            ),
          );
        },
      ),
    );
  }

  void _onDeletePost(NewsfeedPost post) {
    final currentUser = context.read<AuthBloc>().state;

    if (currentUser is AuthAuthenticated &&
        currentUser.user.uid == post.userId) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Xóa bài đăng'),
          content: const Text('Bạn có chắc chắn muốn xóa bài đăng này?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<NewsfeedBloc>().add(DeletePost(postId: post.id));
              },
              child: Text(
                'Xóa',
                style: TextStyle(color: AppColors.error(context)),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      body: Padding(
        padding: EdgeInsets.only(top: widget.paddingTop),
        child: BlocConsumer<NewsfeedBloc, NewsfeedState>(
          listener: (context, state) {
            if (state is NewsfeedError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error(context),
                ),
              );
            } else if (state is PostCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Đăng bài thành công!'),
                  backgroundColor: AppColors.success(context),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is NewsfeedLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is PostsLoaded) {
              return Column(
                children: [
                  // Create post button
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(AppSpacing.md),
                    child: ElevatedButton.icon(
                      onPressed: _showCreatePostDialog,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Chụp ảnh và đăng'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        backgroundColor: AppColors.primary(context),
                        foregroundColor: AppColors.onPrimary(context),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMd,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Posts list
                  Expanded(
                    child: state.posts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.photo_library_outlined,
                                  size: 64,
                                  color: AppColors.onSurfaceVariant(context),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  'Chưa có bài đăng nào',
                                  style: AppTextStyles.headlineSmall.copyWith(
                                    color: AppColors.onSurfaceVariant(context),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  'Hãy chụp ảnh đầu tiên của bạn!',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.onSurfaceVariant(context),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : PageView.builder(
                            itemCount: state.posts.length,
                            scrollDirection: Axis
                                .vertical, // Cho phép kéo lên để xem bài kế tiếp
                            onPageChanged: (index) {
                              // Load more posts khi người dùng kéo gần đến cuối và vẫn còn posts
                              if (index >= state.posts.length - 1 &&
                                  state.hasMorePosts) {
                                context.read<NewsfeedBloc>().add(
                                  const LoadMorePosts(),
                                );
                              }
                            },
                            itemBuilder: (context, index) {
                              final post = state.posts[index];
                              final currentUser = context
                                  .read<AuthBloc>()
                                  .state;
                              final canDelete =
                                  currentUser is AuthAuthenticated &&
                                  currentUser.user.uid == post.userId;

                              return PostCard(
                                post: post,
                                onDelete: canDelete
                                    ? () => _onDeletePost(post)
                                    : null,
                              );
                            },
                          ),
                  ),
                ],
              );
            }

            if (state is NewsfeedError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error(context),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Có lỗi xảy ra',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.error(context),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      state.message,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.onSurfaceVariant(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ElevatedButton(
                      onPressed: () {
                        context.read<NewsfeedBloc>().add(const LoadPosts());
                      },
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }

            return const Center(child: Text('Trạng thái không xác định'));
          },
        ),
      ),
    );
  }
}
