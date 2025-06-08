import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minecraft_compass/models/user_model.dart';
import 'package:minecraft_compass/presentation/compass/minecraft_compass.dart';
import '../friend/bloc/friend_bloc.dart';
import 'bloc/compass_bloc.dart';
import '../auth/bloc/auth_bloc.dart';
import '../../utils/location_utils.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_spacing.dart';
import '../core/widgets/common_avatar.dart';

class CompassPage extends StatefulWidget {
  final double? targetLat;
  final double? targetLng;
  final String? friendName;

  const CompassPage({
    super.key,
    this.targetLat,
    this.targetLng,
    this.friendName,
  });

  @override
  State<CompassPage> createState() => _CompassPageState();
}

class _CompassPageState extends State<CompassPage> {
  UserModel? selectingFriend;
  @override
  void initState() {
    super.initState();
    // Kiểm tra có đích đến không
    if (widget.targetLat != null && widget.targetLng != null) {
      // Có đích đến - sử dụng compass bình thường
      context.read<CompassBloc>().add(
        StartCompass(
          targetLat: widget.targetLat!,
          targetLng: widget.targetLng!,
          friendName: widget.friendName,
        ),
      );
      _getCurrentLocation();
    } else {
      // Không có đích đến - sử dụng chế độ quay ngẫu nhiên
      context.read<CompassBloc>().add(
        StartRandomCompass(friendName: widget.friendName),
      );
    }
  }

  void _getCurrentLocation() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<CompassBloc>().add(
        GetCurrentLocationAndUpdate(uid: authState.user.uid),
      );
    }
  }

  void _onSelectFriend(UserModel friend) {
    setState(() {
      selectingFriend = friend;
    });

    // Check if location data exists before updating
    if (friend.currentLocation?.latitude != null &&
        friend.currentLocation?.longitude != null) {
      // Update target location to point compass to this friend
      context.read<CompassBloc>().add(
        UpdateTargetLocation(
          targetLat: friend.currentLocation!.latitude,
          targetLng: friend.currentLocation!.longitude,
          friendName: friend.displayName,
        ),
      );
    } else {
      // Show error message if friend's location is not available
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${friend.displayName} chưa có thông tin vị trí'),
          backgroundColor: AppColors.error(context),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    // Dừng compass khi widget dispose
    context.read<CompassBloc>().add(const StopCompass());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CompassBloc, CompassState>(
          listener: (context, state) {
            if (state is CompassLocationUpdateSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.onPrimary(context),
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const Text('Vị trí đã được cập nhật'),
                    ],
                  ),
                  backgroundColor: AppColors.primary(context),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
              );
            }
            if (state is CompassError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        Icons.error,
                        color: AppColors.onError(context),
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: Text(state.message)),
                    ],
                  ),
                  backgroundColor: AppColors.error(context),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
              );
            }
          },
        ),
        BlocListener<FriendBloc, FriendState>(
          listener: (context, state) {
            // Future: Add any friend-specific listeners here if needed
          },
        ),
      ],
      child: BlocBuilder<CompassBloc, CompassState>(
        builder: (context, compassState) {
          if (compassState is CompassLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (compassState is CompassError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Lỗi: ${compassState.message}'),
                  ElevatedButton(
                    onPressed: () {
                      if (widget.targetLat != null &&
                          widget.targetLng != null) {
                        // Có đích đến - khởi động lại compass bình thường
                        context.read<CompassBloc>().add(
                          StartCompass(
                            targetLat: widget.targetLat,
                            targetLng: widget.targetLng,
                            friendName: widget.friendName,
                          ),
                        );
                      } else {
                        // Không có đích đến - khởi động lại chế độ random
                        context.read<CompassBloc>().add(
                          StartRandomCompass(friendName: widget.friendName),
                        );
                      }
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (compassState is! CompassReady) {
            return const Center(child: CircularProgressIndicator());
          }
          return Scaffold(
            body: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: AppSpacing.md),

                    // Thông tin đích đến với avatar
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryContainer(context),
                            AppColors.primaryContainer(
                              context,
                            ).withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusXl,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary(context).withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Avatar của người đang chỉ đến
                          if (selectingFriend != null)
                            CommonAvatar(
                              radius: 30,
                              avatarUrl: selectingFriend!.avatarUrl,
                              displayName: selectingFriend!.displayName,
                              backgroundColor: AppColors.primary(context),
                              textColor: AppColors.onPrimary(context),
                            )
                          else
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppColors.primary(
                                  context,
                                ).withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                compassState.targetLat != null
                                    ? Icons.location_on
                                    : Icons.explore,
                                color: AppColors.primary(context),
                                size: 30,
                              ),
                            ),

                          const SizedBox(width: AppSpacing.md),

                          // Thông tin văn bản
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectingFriend?.displayName ??
                                      compassState.friendName ??
                                      (compassState.targetLat != null
                                          ? 'Đích đến'
                                          : 'Chế độ ngẫu nhiên'),
                                  style: AppTextStyles.titleLarge.copyWith(
                                    color: AppColors.onPrimaryContainer(
                                      context,
                                    ),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                if (compassState.distance != null)
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.straighten,
                                        size: 16,
                                        color: AppColors.primary(context),
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Text(
                                        LocationUtils.formatDistance(
                                          compassState.distance!,
                                        ),
                                        style: AppTextStyles.bodyLarge.copyWith(
                                          color: AppColors.primary(context),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  )
                                else if (compassState.targetLat == null)
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.explore,
                                        size: 16,
                                        color: AppColors.primary(context),
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Text(
                                        'Đang quay ngẫu nhiên',
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                              color: AppColors.primary(context),
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: AppSpacing.lg,
                    ), // MinecraftCompass với góc hướng về đích
                    MinecraftCompass(
                      width: AppSpacing.compassSize,
                      height: AppSpacing.compassSize,
                      angle: compassState.compassAngle,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Danh sách các bạn bè (nếu có) - Làm đẹp hơn
                    BlocBuilder<FriendBloc, FriendState>(
                      builder: (context, state) {
                        if (state is FriendAndRequestsLoadSuccess) {
                          if (state.friends.isEmpty) {
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                              ),
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant(context),
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusLg,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    size: 48,
                                    color: AppColors.onSurfaceVariant(context),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    'Chưa có bạn bè nào',
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      color: AppColors.onSurfaceVariant(
                                        context,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Danh sách bạn bè',
                                            style: AppTextStyles.titleLarge,
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          Expanded(child: Container()),
                                          // Nút cập nhật vị trí nhỏ
                                          ElevatedButton.icon(
                                            onPressed: _getCurrentLocation,
                                            icon: const Icon(
                                              Icons.my_location,
                                              size: 16,
                                            ),
                                            label: const Text(
                                              'Cập nhật vị trí',
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.primary(context),
                                              foregroundColor:
                                                  AppColors.onPrimary(context),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: AppSpacing.xs,
                                                    horizontal: AppSpacing.sm,
                                                  ),
                                              minimumSize: Size.zero,
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              textStyle:
                                                  AppTextStyles.bodySmall,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppSpacing.radiusSm,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        'Tip: Chọn một người bạn để tìm họ',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.onSurfaceVariant(
                                            context,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                SizedBox(
                                  height: 120,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                    ),
                                    itemCount: state.friends.length,
                                    itemBuilder: (context, index) {
                                      final friend = state.friends[index];
                                      return GestureDetector(
                                        onTap: () => _onSelectFriend(friend),
                                        child: Container(
                                          width: 80,
                                          margin: const EdgeInsets.only(
                                            right: AppSpacing.md,
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              // Avatar sử dụng CommonAvatar
                                              CommonAvatar(
                                                radius: 35,
                                                avatarUrl: friend.avatarUrl,
                                                displayName: friend.displayName,
                                                backgroundColor:
                                                    AppColors.primary(context),
                                                textColor: AppColors.onPrimary(
                                                  context,
                                                ),
                                                borderColor:
                                                    selectingFriend?.uid ==
                                                        friend.uid
                                                    ? AppColors.primary(context)
                                                    : null,
                                              ),
                                              const SizedBox(
                                                height: AppSpacing.xs2,
                                              ),
                                              // Tên hiển thị
                                              Text(
                                                friend.displayName,
                                                style: AppTextStyles.bodySmall
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          AppColors.onSurface(
                                                            context,
                                                          ),
                                                    ),
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          margin: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant(context),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusLg,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary(context),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Text(
                                'Đang tải danh sách bạn bè...',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.onSurfaceVariant(context),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
