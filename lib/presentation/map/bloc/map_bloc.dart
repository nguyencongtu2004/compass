import 'dart:async';
import 'dart:math' as math;
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

import '../../../data/services/shared_preferences_service.dart';
import '../../../models/user_model.dart';
import '../../../models/newsfeed_post_model.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../friend/bloc/friend_bloc.dart';
import '../../newfeed/bloc/newsfeed_bloc.dart';
import '../widgets/map_toggle_switch.dart';
import '../../core/mixins/bloc_subscription_mixin.dart';

part 'map_event.dart';
part 'map_state.dart';

@lazySingleton
class MapBloc extends Bloc<MapEvent, MapState> with BlocSubscriptionMixin {
  final AuthBloc _authBloc;
  final FriendBloc _friendBloc;
  final NewsfeedBloc _newsfeedBloc;

  Timer? _debounceTimer;

  MapBloc({
    required AuthBloc authBloc,
    required FriendBloc friendBloc,
    required NewsfeedBloc newsfeedBloc,
  }) : _authBloc = authBloc,
       _friendBloc = friendBloc,
       _newsfeedBloc = newsfeedBloc,
       super(const MapInitial()) {
    on<MapInitialized>(_onMapInitialized);
    on<MapModeChanged>(_onMapModeChanged);
    on<MapLocationUpdated>(_onMapLocationUpdated);
    on<MapFriendsUpdated>(_onMapFriendsUpdated);
    on<MapFeedPostsUpdated>(_onMapFeedPostsUpdated);
    on<MapPositionChanged>(_onMapPositionChanged);    on<MapAutoFitBoundsRequested>(_onMapAutoFitBoundsRequested);
    on<MapLoadPostsByLocationRequested>(_onMapLoadPostsByLocationRequested);
    on<MapDefaultLocationSet>(_onMapDefaultLocationSet);
    on<MapResetRequested>(_onMapResetRequested);
    on<MapPostDetailVisibilityChanged>(_onMapPostDetailVisibilityChanged);

    // Lắng nghe thay đổi từ các BLoC khác
    _setupBlocListeners();
  }
  void _setupBlocListeners() {
    addSubscription(
      _authBloc.stream.listen((authState) {
        // TODO: Handle auth state changes if needed
      }),
    );
    addSubscription(
      _friendBloc.stream.listen((friendState) {
        if (friendState is FriendAndRequestsLoadSuccess) {
          final friends = friendState.friends
              .where(
                (friend) =>
                    friend.currentLocation?.latitude != null &&
                    friend.currentLocation?.longitude != null,
              )
              .toList();
          add(MapFriendsUpdated(friends));

          // Nếu đang ở chế độ friends, tự động load posts của bạn bè
          if (state is MapReady) {
            final currentState = state as MapReady;
            if (currentState.currentMode == MapDisplayMode.friends) {
              final authState = _authBloc.state;
              if (authState is AuthAuthenticated) {
                final friendUids = friendState.friends
                    .map((friend) => friend.uid)
                    .toList();
                _newsfeedBloc.add(
                  LoadFriendPosts(
                    currentUserId: authState.user.uid,
                    friendUids: friendUids,
                  ),
                );
              }
            }
          }
        }
      }),
    );
    addSubscription(
      _newsfeedBloc.stream.listen((newsfeedState) {
        if (newsfeedState is PostsLoaded) {
          // NewsfeedBloc hiện tại chỉ có 2 loại posts: friends và explore
          // Lấy posts có location để hiển thị trên map
          final feedPosts = newsfeedState.posts
              .where((post) => post.location != null)
              .toList();
          add(MapFeedPostsUpdated(feedPosts));
        }
      }),
    );
  }
  void _onMapInitialized(MapInitialized event, Emitter<MapState> emit) async {
    emit(const MapLoading());

    try {
      // Load default location từ cache fitBounds hoặc fallback
      final defaultLocation = await _loadDefaultLocation();
      
      // Load cached user location riêng biệt (từ cache location, không phải fitBounds)
      final cachedUserLocation = await _loadCachedUserLocation();

      // Kiểm tra xem có cached fitBounds không để xác định zoom level
      final cachedFitBounds =
          await SharedPreferencesService.getCachedFitBounds();
      final initialZoom = cachedFitBounds?['zoom']?.toDouble() ?? 15.0;

      emit(
        MapReady(
          defaultLocation: defaultLocation,
          cachedUserLocation: cachedUserLocation,
          friends: const [],
          feedPosts: const [],
          currentMode: MapDisplayMode.friends,
          firstTimeLoadExplore: true,
          boundsPoints: const [],
          shouldAutoFitBounds: false,
          initialZoom: initialZoom,
        ),
      );

      // Load data tương ứng với mode mặc định (friends)
      _loadDataForMode(MapDisplayMode.friends);
    } catch (e) {
      emit(MapError('Không thể khởi tạo map: ${e.toString()}'));
    }
  }

  void _onMapModeChanged(MapModeChanged event, Emitter<MapState> emit) {
    if (state is! MapReady) return;

    final currentState = state as MapReady;

    // Cập nhật mode và trigger auto fit bounds
    emit(
      currentState.copyWith(currentMode: event.mode, shouldAutoFitBounds: true),
    );

    // Load data tương ứng với mode mới
    _loadDataForMode(event.mode);
  }

  void _onMapLocationUpdated(MapLocationUpdated event, Emitter<MapState> emit) {
    if (state is! MapReady) return;

    final currentState = state as MapReady;
    final isFirstLocation = currentState.currentLocation == null;

    emit(
      currentState.copyWith(
        currentLocation: event.location,
        shouldAutoFitBounds: isFirstLocation && event.location != null,
      ),
    );
  }

  void _onMapFriendsUpdated(MapFriendsUpdated event, Emitter<MapState> emit) {
    if (state is! MapReady) return;

    final currentState = state as MapReady;
    bool shouldAutoFit = false;

    // Chỉ auto fit bounds khi ở chế độ locations và có friends
    if (currentState.currentMode == MapDisplayMode.locations &&
        event.friends.isNotEmpty) {
      shouldAutoFit = true;
    }

    emit(
      currentState.copyWith(
        friends: event.friends,
        shouldAutoFitBounds: shouldAutoFit,
      ),
    );
  }

  void _onMapFeedPostsUpdated(
    MapFeedPostsUpdated event,
    Emitter<MapState> emit,
  ) {
    if (state is! MapReady) return;

    final currentState = state as MapReady;
    bool shouldAutoFit = false;
    bool firstTimeExplore = currentState.firstTimeLoadExplore;
    switch (currentState.currentMode) {
      case MapDisplayMode.locations:
        // Chế độ xem vị trí: chỉ hiển thị friends và mình, không cần fit bounds theo posts
        shouldAutoFit = false;
        break;
      case MapDisplayMode.friends:
        // Chế độ xem posts bạn bè: hiển thị posts từ mình và bạn bè, fit bounds nếu có posts
        shouldAutoFit = event.feedPosts.isNotEmpty;
        break;
      case MapDisplayMode.explore:
        // Chế độ khám phá: hiển thị posts từ người lạ và mình, fit bounds chỉ lần đầu load
        shouldAutoFit = event.feedPosts.isNotEmpty && firstTimeExplore;
        if (shouldAutoFit) firstTimeExplore = false;
        break;
    }

    emit(
      currentState.copyWith(
        feedPosts: event.feedPosts,
        firstTimeLoadExplore: firstTimeExplore,
        shouldAutoFitBounds: shouldAutoFit,
      ),
    );
  }

  void _onMapPositionChanged(MapPositionChanged event, Emitter<MapState> emit) {
    if (state is! MapReady) return;

    final currentState = state as MapReady;

    // Chỉ xử lý position changed cho explore mode
    if (currentState.currentMode == MapDisplayMode.explore &&
        currentState.currentLocation != null) {
      // Debounce để tránh quá nhiều requests
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        add(
          MapLoadPostsByLocationRequested(
            center: event.center,
            zoom: event.zoom,
          ),
        );
      });
    }
  }

  void _onMapAutoFitBoundsRequested(
    MapAutoFitBoundsRequested event,
    Emitter<MapState> emit,
  ) {
    if (state is! MapReady) return;

    final currentState = state as MapReady;

    emit(currentState.copyWith(shouldAutoFitBounds: true));
  }

  void _onMapLoadPostsByLocationRequested(
    MapLoadPostsByLocationRequested event,
    Emitter<MapState> emit,
  ) {
    if (state is! MapReady) return;

    final currentState = state as MapReady;

    // Chỉ load posts by location trong explore mode
    if (currentState.currentMode == MapDisplayMode.explore) {
      final authState = _authBloc.state;
      if (authState is! AuthAuthenticated) return;

      final currentUserId = authState.user.uid;

      // Tính bán kính từ zoom level
      final radius = _calculateRadiusFromZoom(customZoom: event.zoom);

      // Lấy danh sách friend UIDs để loại trừ (chỉ hiển thị posts của người lạ + mình)
      List<String>? excludeFriendUids;
      final friendState = _friendBloc.state;
      if (friendState is FriendAndRequestsLoadSuccess) {
        excludeFriendUids = friendState.friends
            .map((friend) => friend.uid)
            .toList();
      }

      _newsfeedBloc.add(
        LoadPostsByLocation(
          currentLat: event.center.latitude,
          currentLng: event.center.longitude,
          radiusInMeters: radius,
          excludeFriendUids: excludeFriendUids,
          currentUserId: currentUserId,
        ),
      );
    }
  }

  void _onMapDefaultLocationSet(
    MapDefaultLocationSet event,
    Emitter<MapState> emit,
  ) {
    if (state is! MapReady) return;

    final currentState = state as MapReady;

    emit(currentState.copyWith(defaultLocation: event.defaultLocation));
  } // Helper methods

  Future<LatLng> _loadDefaultLocation() async {
    try {
      // Ưu tiên lấy từ cached fitBounds trước cho default location
      final cachedFitBounds =
          await SharedPreferencesService.getCachedFitBounds();
      if (cachedFitBounds != null) {
        return LatLng(
          cachedFitBounds['latitude']!,
          cachedFitBounds['longitude']!,
        );
      }

      // Nếu không có fitBounds cache, lấy từ cached location
      final cachedLocation = await SharedPreferencesService.getCachedLocation();
      if (cachedLocation != null) {
        return LatLng(
          cachedLocation['latitude']!,
          cachedLocation['longitude']!,
        );
      } else {
        // Fallback to Hanoi coordinates if no cached data
        return const LatLng(21.0285, 105.8542);
      }
    } catch (e) {
      // Fallback to Hanoi coordinates on error
      return const LatLng(21.0285, 105.8542);
    }
  }

  Future<LatLng?> _loadCachedUserLocation() async {
    try {
      // Chỉ lấy từ cached location (vị trí người dùng), không lấy từ fitBounds
      final cachedLocation = await SharedPreferencesService.getCachedLocation();
      if (cachedLocation != null) {
        return LatLng(
          cachedLocation['latitude']!,
          cachedLocation['longitude']!,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void _loadDataForMode(MapDisplayMode mode) {
    final authState = _authBloc.state;
    if (authState is! AuthAuthenticated) return;

    final currentUserId = authState.user.uid;

    switch (mode) {
      case MapDisplayMode.locations:
        // Load friends locations - chỉ cần load friends, không cần posts
        _friendBloc.add(LoadFriendsAndRequests(currentUserId));
        break;
      case MapDisplayMode.friends:
        // Load friends trước, sau đó posts sẽ được load tự động thông qua listener
        _friendBloc.add(LoadFriendsAndRequests(currentUserId));
        
        // Nếu friends đã được load rồi thì load posts ngay
        final friendState = _friendBloc.state;
        if (friendState is FriendAndRequestsLoadSuccess) {
          final friendUids = friendState.friends
              .map((friend) => friend.uid)
              .toList();
          _newsfeedBloc.add(
            LoadFriendPosts(
              currentUserId: currentUserId,
              friendUids: friendUids,
            ),
          );
        }
        break;

      case MapDisplayMode.explore:
        // Load posts by location - sẽ được trigger khi có position change
        // Hoặc load ngay lập tức nếu có vị trí hiện tại
        if (state is MapReady) {
          final currentState = state as MapReady;
          if (currentState.currentLocation != null) {
            final radius = _calculateRadiusFromZoom();

            // Lấy danh sách friend UIDs để loại trừ
            List<String>? excludeFriendUids;
            final friendState = _friendBloc.state;
            if (friendState is FriendAndRequestsLoadSuccess) {
              excludeFriendUids = friendState.friends
                  .map((friend) => friend.uid)
                  .toList();
            }

            _newsfeedBloc.add(
              LoadPostsByLocation(
                currentLat: currentState.currentLocation!.latitude,
                currentLng: currentState.currentLocation!.longitude,
                radiusInMeters: radius,
                excludeFriendUids: excludeFriendUids,
                currentUserId: currentUserId,
              ),
            );
          }
        }
        break;
    }
  }

  // Tính bán kính từ zoom level thực tế của map
  double _calculateRadiusFromZoom({double? customZoom}) {
    // Lấy zoom level thực tế từ map controller hoặc sử dụng giá trị được truyền vào
    final double currentZoom = customZoom ?? 15.0; // default zoom

    // Tính toán bán kính dựa trên zoom level thực tế
    // Công thức: bán kính tỉ lệ nghịch với zoom level
    // Zoom level càng cao (zoom in) thì bán kính càng nhỏ
    const double baseRadius = 1000; // 1000m tại zoom level 15
    const double baseZoom = 15.0;

    // Tính bán kính theo công thức exponential
    final double radius = baseRadius * math.pow(2, baseZoom - currentZoom);

    if (state is MapReady) {
      final currentState = state as MapReady;
      // Đối với explore mode, sử dụng bán kính lớn hơn để tìm nhiều posts hơn
      if (currentState.currentMode == MapDisplayMode.explore) {
        // Gấp đôi bán kính cho explore mode để tìm posts từ người lạ
        final double exploreRadius = radius * 2;
        // Tối thiểu 2km cho explore mode
        return exploreRadius.clamp(2000, 1650000);
      }
    }

    // Giới hạn từ 100m đến 1650km cho các mode khác
    return radius.clamp(100, 1650000);
  }

  void _onMapResetRequested(MapResetRequested event, Emitter<MapState> emit) {
    // Reset map về trạng thái ban đầu
    emit(const MapInitial());
  }

  void _onMapPostDetailVisibilityChanged(
    MapPostDetailVisibilityChanged event,
    Emitter<MapState> emit,
  ) {
    if (state is MapReady) {
      final currentState = state as MapReady;
      emit(currentState.copyWith(isPostDetailVisible: event.isPostDetailVisible));
    }
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super
        .close(); // BlocSubscriptionMixin sẽ tự động cancel tất cả subscriptions
  }
}
