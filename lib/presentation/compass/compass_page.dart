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
  final String? mode;

  const CompassPage({
    super.key,
    this.targetLat,
    this.targetLng,
    this.friendName,
    this.mode,
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
      context.read<FriendBloc>().add(
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
    return Scaffold(
      appBar: AppBar(title: const Text('La bàn')),
      body: MultiBlocListener(
        listeners: [
          BlocListener<FriendBloc, FriendState>(
            listener: (context, state) {
              if (state is LocationLoadSuccess) {
                // Cập nhật vị trí hiện tại vào CompassBloc
                context.read<CompassBloc>().add(
                  UpdateCurrentLocation(
                    latitude: state.location.latitude,
                    longitude: state.location.longitude,
                  ),
                );
              }
              if (state is LocationFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error(context),
                  ),
                );
              }
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

            return SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Thông tin đích đến
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      margin: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer(context),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusLg,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            compassState.friendName ??
                                (compassState.targetLat != null
                                    ? 'Đích đến'
                                    : 'Chế độ ngẫu nhiên'),
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.onPrimaryContainer(context),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.xs2),
                          if (compassState.distance != null)
                            Text(
                              'Cách ${LocationUtils.formatDistance(compassState.distance!)}',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.primary(context),
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          else if (compassState.targetLat == null)
                            Text(
                              'Kim la bàn đang quay ngẫu nhiên',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.primary(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // MinecraftCompass với góc hướng về đích
                    MinecraftCompass(
                      width: AppSpacing.compassSize,
                      height: AppSpacing.compassSize,
                      angle: compassState.compassAngle,
                    ),

                    const SizedBox(height: AppSpacing.md4),

                    // Danh sách các bạn bè (nếu có)
                    BlocBuilder<FriendBloc, FriendState>(
                      builder: (context, state) {
                        if (state is FriendAndRequestsLoadSuccess) {
                          if (state.friends.isEmpty) {
                            return Container();
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
                                  child: Text(
                                    'Danh sách bạn bè:',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onSurface(context),
                                    ),
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
                          padding: const EdgeInsets.all(AppSpacing.md),
                          margin: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant(context),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                          ),
                          child: const Text(
                            'Đang tải danh sách bạn bè...',
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: AppSpacing.md),
                    ElevatedButton.icon(
                      onPressed: _getCurrentLocation,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Cập nhật vị trí'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
