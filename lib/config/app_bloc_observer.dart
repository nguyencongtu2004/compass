import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minecraft_compass/presentation/compass/bloc/compass_bloc.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    if (event is UpdateCompassHeading || event is UpdateRandomAngle) {
      return;
    }
    debugPrint('[Bloc Event - ${bloc.runtimeType}] $event');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    if (transition.event is UpdateCompassHeading ||
        transition.event is UpdateRandomAngle) {
      return;
    }
    debugPrint('[Bloc Transition - ${bloc.runtimeType}] $transition');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    debugPrint('[Bloc Error - ${bloc.runtimeType}] $error');
  }
}
