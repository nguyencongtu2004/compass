import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minecraft_compass/router/app_routes.dart';
import '../presentation/auth/login_page.dart';
import '../presentation/auth/register_page.dart';
import '../presentation/friend/friend_list_page.dart';
import '../presentation/friend/friend_request_page.dart';
import '../presentation/location/compass_page.dart';
import '../presentation/profile/profile_page.dart';
import '../core/common/home_page.dart';
import '../presentation/auth/bloc/auth_bloc.dart';

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
      initialLocation: AppRoutes.loginRoute,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final isLoggedIn = authBloc.state is AuthAuthenticated;
        final goingToLogin =
            state.uri.toString() == AppRoutes.loginRoute ||
            state.uri.toString() == AppRoutes.registerRoute;

        if (!isLoggedIn && !goingToLogin) {
          return AppRoutes.loginRoute;
        }
        if (isLoggedIn && goingToLogin) {
          return AppRoutes.homeRoute;
        }
        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.loginRoute,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: AppRoutes.registerRoute,
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: AppRoutes.homeRoute,
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
