import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minecraft_compass/models/user_model.dart';
import 'package:minecraft_compass/presentation/profile/edit_profile_page.dart';
import 'package:minecraft_compass/router/app_routes.dart';
import '../presentation/auth/login_page.dart';
import '../presentation/auth/register_page.dart';
import '../presentation/friend/friend_list_page.dart';
import '../presentation/compass/compass_page.dart';
import '../presentation/home/home_page.dart';
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
      debugLogDiagnostics: true,
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
          builder: (context, state) =>
              const HomePage(initialPage: 1), // Compass page
          routes: [
            GoRoute(
              path: 'profile',
              builder: (context, state) =>
                  const HomePage(initialPage: 0), // Profile page
            ),
            GoRoute(
              path: 'compass',
              builder: (context, state) {
                // Nếu có tham số lat/lng, mở compass trực tiếp
                final lat = double.tryParse(
                  state.uri.queryParameters['lat'] ?? '',
                );
                final lng = double.tryParse(
                  state.uri.queryParameters['lng'] ?? '',
                );
                final friendName =
                    state.uri.queryParameters['friendName'] ?? '';
                final mode = state.uri.queryParameters['mode'] ?? 'fixed';

                if (lat != null && lng != null) {
                  return CompassPage(
                    targetLat: lat,
                    targetLng: lng,
                    friendName: friendName,
                    mode: mode,
                  );
                }
                // Nếu không có tham số, hiện home page với compass tab
                return const HomePage(initialPage: 1);
              },
            ),
            GoRoute(
              path: 'friends',
              builder: (context, state) =>
                  const HomePage(initialPage: 2), // Friends page
            ),
            GoRoute(
              path: 'friend_list',
              builder: (context, state) => const FriendListPage(),
            ),
          ],
        ),
        GoRoute(path: AppRoutes.editProfileRoute,
          builder: (context, state) {
            final user = state.extra as UserModel;
            return EditProfilePage(user: user);
          },
        ),
      ],
    );
  }
}
