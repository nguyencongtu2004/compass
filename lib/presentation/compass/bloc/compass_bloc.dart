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
  Timer? _randomCompassTimer;
  double _currentRandomAngle = 0.0; // Lưu góc ngẫu nhiên hiện tại

  CompassBloc() : super(CompassInitial()) {
    on<StartCompass>(_onStartCompass);
    on<StartRandomCompass>(_onStartRandomCompass);
    on<UpdateCompassHeading>(_onUpdateCompassHeading);
    on<UpdateRandomAngle>(_onUpdateRandomAngle);
    on<UpdateCurrentLocation>(_onUpdateCurrentLocation);
    on<RefreshCurrentLocation>(_onRefreshCurrentLocation);
    on<StopCompass>(_onStopCompass);
    on<UpdateTargetLocation>(_onUpdateTargetLocation);
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

  void _onStartRandomCompass(
    StartRandomCompass event,
    Emitter<CompassState> emit,
  ) {
    emit(CompassLoading());

    // Khởi tạo góc ngẫu nhiên ban đầu
    _currentRandomAngle = Random().nextDouble() * 2 * pi;

    // Khởi tạo state với chế độ random (không có đích đến)
    emit(
      CompassReady(
        targetLat: null,
        targetLng: null,
        friendName: event.friendName,
        compassAngle: _currentRandomAngle,
      ),
    );

    // Bắt đầu chế độ quay ngẫu nhiên
    _startRandomCompassStream();
  }

  void _onUpdateCompassHeading(
    UpdateCompassHeading event,
    Emitter<CompassState> emit,
  ) {
    if (state is CompassReady) {
      final currentState = state as CompassReady;

      // Nếu không có đích đến, bỏ qua việc cập nhật từ cảm biến
      if (currentState.targetLat == null || currentState.targetLng == null) {
        return;
      }

      // Tính toán khoảng cách nếu có vị trí hiện tại
      double? distance;
      if (currentState.currentLat != null && currentState.currentLng != null) {
        distance = LocationUtils.calculateDistance(
          currentState.currentLat!,
          currentState.currentLng!,
          currentState.targetLat!,
          currentState.targetLng!,
        );
      }

      // Tính góc compass
      final compassAngle = _calculateCompassAngle(
        heading: event.heading,
        currentLat: currentState.currentLat,
        currentLng: currentState.currentLng,
        targetLat: currentState.targetLat!,
        targetLng: currentState.targetLng!,
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

  void _onUpdateRandomAngle(
    UpdateRandomAngle event,
    Emitter<CompassState> emit,
  ) {
    if (state is CompassReady) {
      final currentState = state as CompassReady;

      // Chỉ cập nhật góc random nếu không có đích đến
      if (currentState.targetLat == null || currentState.targetLng == null) {
        emit(currentState.copyWith(compassAngle: event.angle));
      }
    }
  }

  void _onUpdateCurrentLocation(
    UpdateCurrentLocation event,
    Emitter<CompassState> emit,
  ) {
    if (state is CompassReady) {
      final currentState = state as CompassReady;

      // Nếu không có đích đến, bỏ qua việc cập nhật
      if (currentState.targetLat == null || currentState.targetLng == null) {
        emit(
          currentState.copyWith(
            currentLat: event.latitude,
            currentLng: event.longitude,
          ),
        );
        return;
      }

      // Tính toán khoảng cách
      final distance = LocationUtils.calculateDistance(
        event.latitude,
        event.longitude,
        currentState.targetLat!,
        currentState.targetLng!,
      );

      // Tính góc compass
      final compassAngle = _calculateCompassAngle(
        heading: currentState.heading,
        currentLat: event.latitude,
        currentLng: event.longitude,
        targetLat: currentState.targetLat!,
        targetLng: currentState.targetLng!,
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
    _randomCompassTimer?.cancel();
    _randomCompassTimer = null;
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

  void _startRandomCompassStream() {
    _randomCompassTimer?.cancel();
    _randomCompassTimer = Timer.periodic(const Duration(milliseconds: 200), (
      timer,
    ) {
      // Tạo góc ngẫu nhiên mượt mà
      final newAngle = _generateSmoothRandomAngle();

      // Gửi event để cập nhật góc ngẫu nhiên
      add(UpdateRandomAngle(newAngle));
    });
  }

  /// Tạo góc ngẫu nhiên mượt mà với delta giới hạn
  double _generateSmoothRandomAngle() {
    // Giới hạn độ thay đổi tối đa cho mỗi lần update (tính bằng radian)
    const double maxDelta = pi / 8; // Khoảng 22.5 độ

    // Tạo delta ngẫu nhiên trong khoảng [-maxDelta, +maxDelta]
    final double delta = (Random().nextDouble() - 0.5) * 2 * maxDelta;

    // Cập nhật góc hiện tại
    _currentRandomAngle += delta;

    // Chuẩn hóa góc về khoảng [0, 2π]
    while (_currentRandomAngle < 0) {
      _currentRandomAngle += 2 * pi;
    }
    while (_currentRandomAngle >= 2 * pi) {
      _currentRandomAngle -= 2 * pi;
    }

    return _currentRandomAngle;
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

  void _onUpdateTargetLocation(
    UpdateTargetLocation event,
    Emitter<CompassState> emit,
  ) {
    if (state is CompassReady) {
      final currentState = state as CompassReady;

      // Dừng timer random nếu đang chạy
      _randomCompassTimer?.cancel();
      _randomCompassTimer = null;

      // Bắt đầu compass stream thật để tính toán hướng chính xác
      _startCompassStream();

      // Tính toán góc compass ngay lập tức nếu có đủ thông tin
      double compassAngle = 0.0;
      double? distance;

      if (currentState.heading != null &&
          currentState.currentLat != null &&
          currentState.currentLng != null) {
        // Tính khoảng cách
        distance = LocationUtils.calculateDistance(
          currentState.currentLat!,
          currentState.currentLng!,
          event.targetLat,
          event.targetLng,
        );

        // Tính góc compass
        compassAngle = _calculateCompassAngle(
          heading: currentState.heading,
          currentLat: currentState.currentLat,
          currentLng: currentState.currentLng,
          targetLat: event.targetLat,
          targetLng: event.targetLng,
        );
      } // Cập nhật vị trí đích đến và thông tin tính toán
      emit(
        currentState.copyWith(
          targetLat: event.targetLat,
          targetLng: event.targetLng,
          friendName: event.friendName,
          distance: distance,
          compassAngle: compassAngle,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _compassSubscription?.cancel();
    _randomCompassTimer?.cancel();
    return super.close();
  }
}
