import 'dart:async';
import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_compass/flutter_compass.dart' as compass;
import '../../../utils/location_utils.dart';

part 'compass_event.dart';
part 'compass_state.dart';

class CompassBloc extends Bloc<CompassEvent, CompassState> {
  StreamSubscription<compass.CompassEvent>? _compassSubscription;

  CompassBloc() : super(CompassInitial()) {
    on<StartCompass>(_onStartCompass);
    on<UpdateCompassHeading>(_onUpdateCompassHeading);
    on<UpdateCurrentLocation>(_onUpdateCurrentLocation);
    on<RefreshCurrentLocation>(_onRefreshCurrentLocation);
    on<StopCompass>(_onStopCompass);
  }

  void _onStartCompass(StartCompass event, Emitter<CompassState> emit) {
    emit(CompassLoading());

    // Khởi tạo state với thông tin đích đến
    emit(
      CompassReady(
        targetLat: event.targetLat,
        targetLng: event.targetLng,
        friendName: event.friendName,
        compassAngle: 0.0,
      ),
    );

    // Bắt đầu lắng nghe compass
    _startCompassStream();
  }

  void _onUpdateCompassHeading(
    UpdateCompassHeading event,
    Emitter<CompassState> emit,
  ) {
    if (state is CompassReady) {
      final currentState = state as CompassReady;

      // Tính toán khoảng cách nếu có vị trí hiện tại
      double? distance;
      if (currentState.currentLat != null && currentState.currentLng != null) {
        distance = LocationUtils.calculateDistance(
          currentState.currentLat!,
          currentState.currentLng!,
          currentState.targetLat,
          currentState.targetLng,
        );
      }

      // Tính góc compass
      final compassAngle = _calculateCompassAngle(
        heading: event.heading,
        currentLat: currentState.currentLat,
        currentLng: currentState.currentLng,
        targetLat: currentState.targetLat,
        targetLng: currentState.targetLng,
      );

      emit(
        currentState.copyWith(
          heading: event.heading,
          distance: distance,
          compassAngle: compassAngle,
        ),
      );
    }
  }

  void _onUpdateCurrentLocation(
    UpdateCurrentLocation event,
    Emitter<CompassState> emit,
  ) {
    if (state is CompassReady) {
      final currentState = state as CompassReady;

      // Tính toán khoảng cách
      final distance = LocationUtils.calculateDistance(
        event.latitude,
        event.longitude,
        currentState.targetLat,
        currentState.targetLng,
      );

      // Tính góc compass
      final compassAngle = _calculateCompassAngle(
        heading: currentState.heading,
        currentLat: event.latitude,
        currentLng: event.longitude,
        targetLat: currentState.targetLat,
        targetLng: currentState.targetLng,
      );

      emit(
        currentState.copyWith(
          currentLat: event.latitude,
          currentLng: event.longitude,
          distance: distance,
          compassAngle: compassAngle,
        ),
      );
    }
  }

  void _onRefreshCurrentLocation(
    RefreshCurrentLocation event,
    Emitter<CompassState> emit,
  ) {
    // Event này sẽ được gửi từ UI để trigger việc refresh location từ FriendBloc
    // Logic thực tế sẽ được xử lý ở UI layer
  }

  void _onStopCompass(StopCompass event, Emitter<CompassState> emit) {
    _compassSubscription?.cancel();
    _compassSubscription = null;
    emit(CompassInitial());
  }

  void _startCompassStream() {
    _compassSubscription?.cancel();
    _compassSubscription = compass.FlutterCompass.events?.listen((
      compass.CompassEvent compassEvent,
    ) {
      if (compassEvent.heading != null) {
        add(UpdateCompassHeading(compassEvent.heading!));
      }
    });
  }

  /// Tính góc cho MinecraftCompass để hướng kim về đích
  /// Trả về góc tính bằng radian
  double _calculateCompassAngle({
    double? heading,
    double? currentLat,
    double? currentLng,
    required double targetLat,
    required double targetLng,
  }) {
    if (heading == null || currentLat == null || currentLng == null) {
      return 0.0; // Mặc định hướng Bắc
    }

    // Tính bearing từ vị trí hiện tại đến đích
    final bearing = LocationUtils.calculateBearing(
      currentLat,
      currentLng,
      targetLat,
      targetLng,
    );

    // Tính góc tương đối giữa bearing và heading của điện thoại
    double angleDiff = bearing - heading;

    // Chuẩn hóa về khoảng -180 đến 180
    while (angleDiff > 180) {
      angleDiff -= 360;
    }
    while (angleDiff < -180) {
      angleDiff += 360;
    }

    // Chuyển đổi từ độ sang radian
    return angleDiff * pi / 180;
  }

  @override
  Future<void> close() {
    _compassSubscription?.cancel();
    return super.close();
  }
}
