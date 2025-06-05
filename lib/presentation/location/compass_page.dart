import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minecraft_compass/presentation/location/minecraft_compass.dart';
import 'bloc/location_bloc.dart';
import 'bloc/compass_bloc.dart';
import '../auth/bloc/auth_bloc.dart';
import '../../core/utils/location_utils.dart';
import '../../core/common/app_colors.dart';
import '../../core/common/app_text_styles.dart';
import '../../core/common/app_spacing.dart';

class CompassPage extends StatefulWidget {
  final double targetLat;
  final double targetLng;
  final String? friendName;
  final String? mode;

  const CompassPage({
    super.key,
    required this.targetLat,
    required this.targetLng,
    this.friendName,
    this.mode,
  });

  @override
  State<CompassPage> createState() => _CompassPageState();
}

class _CompassPageState extends State<CompassPage> {
  @override
  void initState() {
    super.initState();
    // Khởi tạo CompassBloc và bắt đầu compass
    context.read<CompassBloc>().add(
      StartCompass(
        targetLat: widget.targetLat,
        targetLng: widget.targetLng,
        friendName: widget.friendName,
      ),
    );
    _getCurrentLocation();
  }

  void _getCurrentLocation() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<LocationBloc>().add(GetCurrentLocation());
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
          BlocListener<LocationBloc, LocationState>(
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
                        context.read<CompassBloc>().add(
                          StartCompass(
                            targetLat: widget.targetLat,
                            targetLng: widget.targetLng,
                            friendName: widget.friendName,
                          ),
                        );
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

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Thông tin đích đến
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    margin: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer(context),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    child: Column(
                      children: [
                        Text(
                          compassState.friendName ?? 'Đích đến',
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

                  // Thông tin tọa độ
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant(context),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Vị trí hiện tại:',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurfaceVariant(context),
                          ),
                        ),
                        Text(
                          compassState.currentLat != null &&
                                  compassState.currentLng != null
                              ? 'Lat: ${compassState.currentLat!.toStringAsFixed(6)}\nLng: ${compassState.currentLng!.toStringAsFixed(6)}'
                              : 'Đang lấy vị trí...',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.onSurfaceVariant(context),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs2),
                        Text(
                          'Đích đến:',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurfaceVariant(context),
                          ),
                        ),
                        Text(
                          'Lat: ${compassState.targetLat.toStringAsFixed(6)}\nLng: ${compassState.targetLng.toStringAsFixed(6)}',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.onSurfaceVariant(context),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton.icon(
                    onPressed: _getCurrentLocation,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Cập nhật vị trí'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
