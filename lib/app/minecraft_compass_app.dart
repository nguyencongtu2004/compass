import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minecraft_compass/core/common/app_theme.dart';
import 'package:minecraft_compass/presentation/auth/bloc/auth_bloc.dart';
import 'package:minecraft_compass/presentation/friend/bloc/friend_bloc.dart';
import 'package:minecraft_compass/presentation/location/bloc/location_bloc.dart';
import 'package:minecraft_compass/router/app_router.dart';

class MinecraftCompassApp extends StatelessWidget {
  const MinecraftCompassApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authBloc = AuthBloc();

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authBloc),
        BlocProvider(create: (context) => FriendBloc()),
        BlocProvider(create: (context) => LocationBloc()),
      ],
      child: MaterialApp.router(
        title: 'Minecraft Compass',
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router(authBloc),
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
      ),
    );
  }
}
