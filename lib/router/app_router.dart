import 'package:go_router/go_router.dart';
import 'package:minecraft_compass/models/user_model.dart';
import 'package:minecraft_compass/presentation/friend/friend_list_page.dart';
import 'package:minecraft_compass/presentation/messaging/chat/chat_page.dart';
import 'package:minecraft_compass/presentation/messaging/conversation/conversation_list_page.dart';
import 'package:minecraft_compass/presentation/newfeed/create_post_page.dart';
import 'package:minecraft_compass/presentation/profile/edit_profile_page.dart';
import 'package:minecraft_compass/presentation/splash/splash_page.dart';
import 'package:minecraft_compass/router/app_routes.dart';
import '../presentation/auth/login_page.dart';
import '../presentation/auth/register_page.dart';
import '../presentation/home/home_page.dart';
import '../presentation/compass/compass_page.dart';

class AppRouter {
  static GoRouter router() {
    return GoRouter(
      initialLocation: AppRoutes.splashRoute,
      debugLogDiagnostics: true,
      routes: [
        GoRoute(
          path: AppRoutes.splashRoute, // splash
          builder: (context, state) => const SplashPage(),
        ),
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
          builder: (context, state) {
            final targetLat = double.tryParse(
              state.uri.queryParameters['lat'] ?? '',
            );
            final targetLng = double.tryParse(
              state.uri.queryParameters['lng'] ?? '',
            );
            final friendName = state.uri.queryParameters['friend'];

            return CompassPage(
              targetLat: targetLat,
              targetLng: targetLng,
              friendName: friendName,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.profileRoute, // profile
          builder: (context, state) {
            final initialPage = 0; // Profile page index
            return HomePage(initialPage: initialPage);
          },
        ),
        GoRoute(
          path: AppRoutes.friendListRoute, // friends
          builder: (context, state) {
            return FriendListPage();
          },
        ),
        GoRoute(
          path: AppRoutes.editProfileRoute,
          builder: (context, state) {
            final user = state.extra as UserModel;
            return EditProfilePage(user: user);
          },
        ),
        GoRoute(
          path: AppRoutes.createPostRoute,
          builder: (context, state) => const CreatePostPage(),
        ),
        GoRoute(
          path: AppRoutes.conversationsRoute,
          builder: (context, state) => const ConversationListPage(),
        ),
        GoRoute(
          path: '${AppRoutes.chatRoute}/:conversationId',
          builder: (context, state) {
            final conversationId = state.pathParameters['conversationId']!;
            final extra = state.extra as Map<String, dynamic>?;

            // todo: Handle case where extra is null later
            final otherUid = extra?['otherUid'] as String? ?? '';

            return ChatPage(conversationId: conversationId, otherUid: otherUid);
          },
        ),
      ],
    );
  }
}
