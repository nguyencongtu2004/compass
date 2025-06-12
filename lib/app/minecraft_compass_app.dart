import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:minecraft_compass/presentation/core/theme/app_theme.dart';
import 'package:minecraft_compass/presentation/auth/bloc/auth_bloc.dart';
import 'package:minecraft_compass/presentation/friend/bloc/friend_bloc.dart';
import 'package:minecraft_compass/presentation/compass/bloc/compass_bloc.dart';
import 'package:minecraft_compass/presentation/profile/bloc/profile_bloc.dart';
import 'package:minecraft_compass/presentation/newfeed/bloc/newsfeed_bloc.dart';
import 'package:minecraft_compass/presentation/messaging/conversation/bloc/conversation_bloc.dart';
import 'package:minecraft_compass/presentation/messaging/chat/bloc/message_bloc.dart';
import 'package:minecraft_compass/presentation/map/bloc/map_bloc.dart';
import 'package:minecraft_compass/data/repositories/location_repository.dart';
import 'package:minecraft_compass/router/app_router.dart';

class MinecraftCompassApp extends StatelessWidget {
  const MinecraftCompassApp({super.key});
  @override
  Widget build(BuildContext context) {
    // Tắt native splash screen sau khi app đã build xong
    FlutterNativeSplash.remove();
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()),
        BlocProvider(create: (context) => FriendBloc()),
        BlocProvider(
          create: (context) =>
              CompassBloc(locationRepository: LocationRepository()),
        ),
        BlocProvider(create: (context) => ProfileBloc()),
        BlocProvider(create: (context) => ConversationBloc()),
        BlocProvider(create: (context) => MessageBloc()),
        BlocProvider(
          create: (context) =>
              NewsfeedBloc(profileBloc: context.read<ProfileBloc>()),
        ),
        BlocProvider(
          create: (context) => MapBloc(
            authBloc: context.read<AuthBloc>(),
            friendBloc: context.read<FriendBloc>(),
            newsfeedBloc: context.read<NewsfeedBloc>(),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'Minecraft Compass',
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router(),
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
      ),
    );
  }
}
