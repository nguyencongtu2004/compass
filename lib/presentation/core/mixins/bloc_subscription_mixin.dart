import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Mixin để quản lý subscription tự động trong BLoC
/// Giúp tránh memory leak khi quên cancel subscription
mixin BlocSubscriptionMixin<Event, State> on Bloc<Event, State> {
  final List<StreamSubscription> _subscriptions = [];

  /// Thêm subscription vào danh sách để tự động dispose
  void addSubscription(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }

  /// Hủy tất cả subscriptions
  void cancelAllSubscriptions() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  @override
  Future<void> close() {
    cancelAllSubscriptions();
    return super.close();
  }
}
