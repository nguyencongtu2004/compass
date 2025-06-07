import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minecraft_compass/models/user_model.dart';
import 'package:minecraft_compass/presentation/profile/edit_profile_page.dart';
import 'package:minecraft_compass/router/app_routes.dart';
import '../presentation/auth/login_page.dart';
import '../presentation/auth/register_page.dart';
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
      initialLocation: AppRoutes.homeRoute,
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
          return AppRoutes.compassRoute;
        }
        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.loginRoute, // login
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: AppRoutes.registerRoute, // register
          builder: (context, state) => const RegisterPage(),
        ),

        GoRoute(
          path: AppRoutes.homeRoute, // home
          builder: (context, state) {
            final initialPage =
                int.tryParse(state.uri.queryParameters['page'] ?? '1') ?? 1;
            return HomePage(initialPage: initialPage);
          },
        ),

        GoRoute(
          path: AppRoutes.compassRoute, // compass
          redirect: (context, state) {
            return '${AppRoutes.homeRoute}?page=1'; // Redirect to home with compass page
          },
        ),
        GoRoute(
          path: AppRoutes.profileRoute, // profile
          redirect: (context, state) {
            final user = authBloc.state is AuthAuthenticated
                ? (authBloc.state as AuthAuthenticated).user
                : null;
            if (user != null) {
              return '${AppRoutes.homeRoute}?page=0'; // Redirect to home with profile page
            }
            return null; // No redirect if not authenticated
          },
        ),
        GoRoute(
          path: AppRoutes.friendListRoute, // friends
          builder: (context, state) =>
              const HomePage(initialPage: 2), // Friends page
        ),
        GoRoute(
          path: AppRoutes.editProfileRoute,
          builder: (context, state) {
            final user = state.extra as UserModel;
            return EditProfilePage(user: user);
          },
        ),
      ],
    );
  }
}
