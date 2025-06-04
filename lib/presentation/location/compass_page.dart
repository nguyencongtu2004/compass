import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'bloc/location_bloc.dart';
import '../auth/bloc/auth_bloc.dart';
import '../../core/utils/location_utils.dart';
import '../../core/common/app_colors.dart';
import '../../core/common/app_text_styles.dart';
import '../../core/common/app_spacing.dart';
import '../../core/common/widgets/loading_indicator.dart';

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
  double? _heading;
  double? _currentLat;
  double? _currentLng;
  double? _bearing;
  double? _distance;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _startCompassStream();
  }

  void _getCurrentLocation() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<LocationBloc>().add(GetCurrentLocation());
    }
  }

  void _startCompassStream() {
    FlutterCompass.events?.listen((CompassEvent event) {
      if (mounted) {
        setState(() {
          _heading = event.heading;
          if (_currentLat != null && _currentLng != null) {
            _bearing = LocationUtils.calculateBearing(
              _currentLat!,
              _currentLng!,
              widget.targetLat,
              widget.targetLng,
            );
            _distance = LocationUtils.calculateDistance(
              _currentLat!,
              _currentLng!,
              widget.targetLat,
              widget.targetLng,
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('La bàn')),
      body: BlocListener<LocationBloc, LocationState>(
        listener: (context, state) {
          if (state is LocationLoadSuccess) {
            setState(() {
              _currentLat = state.location.latitude;
              _currentLng = state.location.longitude;
            });
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
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Column(
                  children: [
                    Text(
                      widget.friendName ?? 'Đích đến',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.onPrimaryContainer(context),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs2),
                    if (_distance != null)
                      Text(
                        'Cách ${_distance!.toStringAsFixed(0)}m',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.primary(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),

              // La bàn
              Container(
                width: AppSpacing.compassSize,
                height: AppSpacing.compassSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.compassRing(context),
                    width: AppSpacing.compassRingWidth,
                  ),
                ),
                child: _buildCompass(),
              ),

              const SizedBox(height: AppSpacing.md4),

              // Thông tin tọa độ
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
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
                      _currentLat != null && _currentLng != null
                          ? 'Lat: ${_currentLat!.toStringAsFixed(6)}\nLng: ${_currentLng!.toStringAsFixed(6)}'
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
                      'Lat: ${widget.targetLat.toStringAsFixed(6)}\nLng: ${widget.targetLng.toStringAsFixed(6)}',
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
        ),
      ),
    );
  }

  Widget _buildCompass() {
    if (_heading == null) {
      return const LoadingIndicator();
    }

    return Stack(
      children: [
        // Mặt la bàn
        Container(
          width: AppSpacing.compassSize,
          height: AppSpacing.compassSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.compassBackground(context),
          ),
          child: CustomPaint(
            painter: CompassPainter(
              heading: _heading!,
              bearing: _bearing,
              context: context,
            ),
            size: const Size(AppSpacing.compassSize, AppSpacing.compassSize),
          ),
        ),
      ],
    );
  }
}

class CompassPainter extends CustomPainter {
  final double heading;
  final double? bearing;
  final BuildContext context;

  CompassPainter({required this.heading, this.bearing, required this.context});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Vẽ các điểm chính
    _drawCardinalPoints(canvas, center, radius);

    // Vẽ kim la bàn (luôn chỉ Bắc)
    _drawNorthArrow(canvas, center, radius);

    // Vẽ mũi tên chỉ đích (nếu có bearing)
    if (bearing != null) {
      _drawTargetArrow(canvas, center, radius);
    }
  }

  void _drawCardinalPoints(Canvas canvas, Offset center, double radius) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Vẽ các điểm N, E, S, W
    const directions = ['N', 'E', 'S', 'W'];
    for (int i = 0; i < 4; i++) {
      final angle = (i * 90 - heading) * pi / 180;
      final x = center.dx + (radius - 20) * sin(angle);
      final y = center.dy - (radius - 20) * cos(angle);
      textPainter.text = TextSpan(
        text: directions[i],
        style: TextStyle(
          color: AppColors.onSurface(context),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  void _drawNorthArrow(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = AppColors.compassNeedle(context)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Kim chỉ Bắc (luôn hướng lên)
    final angle = -heading * pi / 180;
    final tipX = center.dx + (radius - 40) * sin(angle);
    final tipY = center.dy - (radius - 40) * cos(angle);

    canvas.drawLine(center, Offset(tipX, tipY), paint);

    // Đầu mũi tên
    final leftX = center.dx + (radius - 60) * sin(angle - 0.3);
    final leftY = center.dy - (radius - 60) * cos(angle - 0.3);
    final rightX = center.dx + (radius - 60) * sin(angle + 0.3);
    final rightY = center.dy - (radius - 60) * cos(angle + 0.3);

    canvas.drawLine(Offset(tipX, tipY), Offset(leftX, leftY), paint);
    canvas.drawLine(Offset(tipX, tipY), Offset(rightX, rightY), paint);
  }

  void _drawTargetArrow(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = AppColors.primary(context)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    // Mũi tên chỉ đích
    final angle = (bearing! - heading) * pi / 180;
    final tipX = center.dx + (radius - 50) * sin(angle);
    final tipY = center.dy - (radius - 50) * cos(angle);

    canvas.drawLine(center, Offset(tipX, tipY), paint);

    // Đầu mũi tên
    final leftX = center.dx + (radius - 70) * sin(angle - 0.4);
    final leftY = center.dy - (radius - 70) * cos(angle - 0.4);
    final rightX = center.dx + (radius - 70) * sin(angle + 0.4);
    final rightY = center.dy - (radius - 70) * cos(angle + 0.4);

    canvas.drawLine(Offset(tipX, tipY), Offset(leftX, leftY), paint);
    canvas.drawLine(Offset(tipX, tipY), Offset(rightX, rightY), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
