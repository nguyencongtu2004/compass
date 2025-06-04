import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/login_page.dart';
import '../screens/auth/register_page.dart';
import '../screens/friend/friend_list_page.dart';
import '../screens/friend/friend_request_page.dart';
import '../screens/compass/compass_page.dart';
import '../screens/profile/profile_page.dart';
import '../screens/home/home_page.dart';
import '../blocs/auth/auth_bloc.dart';
import '../constants/app_constants.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  static GoRouter router(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: AppConstants.loginRoute,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final isLoggedIn = authBloc.state is AuthAuthenticated;
        final goingToLogin =
            state.uri.toString() == AppConstants.loginRoute ||
            state.uri.toString() == AppConstants.registerRoute;

        if (!isLoggedIn && !goingToLogin) {
          return AppConstants.loginRoute;
        }
        if (isLoggedIn && goingToLogin) {
          return AppConstants.homeRoute;
        }
        return null;
      },
      routes: [
        GoRoute(
          path: AppConstants.loginRoute,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: AppConstants.registerRoute,
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: AppConstants.homeRoute,
          builder: (context, state) => const HomePage(),
          routes: [
            GoRoute(
              path: 'friend_list',
              builder: (context, state) => const FriendListPage(),
            ),
            GoRoute(
              path: 'friend_requests',
              builder: (context, state) => const FriendRequestPage(),
            ),
            GoRoute(
              path: 'compass',
              builder: (context, state) {
                final lat = double.tryParse(
                  state.uri.queryParameters['lat'] ?? '',
                );
                final lng = double.tryParse(
                  state.uri.queryParameters['lng'] ?? '',
                );
                final friendName =
                    state.uri.queryParameters['friendName'] ?? '';
                final mode = state.uri.queryParameters['mode'] ?? 'fixed';

                if (lat == null || lng == null) {
                  return const Scaffold(
                    body: Center(child: Text('Thiếu tham số tọa độ')),
                  );
                }
                return CompassPage(
                  targetLat: lat,
                  targetLng: lng,
                  friendName: friendName,
                  mode: mode,
                );
              },
            ),
            GoRoute(
              path: 'profile',
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
    );
  }
}
