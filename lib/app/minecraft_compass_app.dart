import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:minecraft_compass/data/repositories/auth_repository.dart';
import 'package:minecraft_compass/data/repositories/user_repository.dart';
import 'package:minecraft_compass/di/injection.dart';
import 'package:minecraft_compass/presentation/core/theme/app_theme.dart';
import 'package:minecraft_compass/presentation/auth/bloc/auth_bloc.dart';
import 'package:minecraft_compass/presentation/friend/bloc/friend_bloc.dart';
import 'package:minecraft_compass/presentation/compass/bloc/compass_bloc.dart';
import 'package:minecraft_compass/presentation/profile/bloc/profile_bloc.dart';
import 'package:minecraft_compass/presentation/newfeed/bloc/newsfeed_bloc.dart';
import 'package:minecraft_compass/presentation/messaging/conversation/bloc/conversation_bloc.dart';
import 'package:minecraft_compass/presentation/map/bloc/map_bloc.dart';
import 'package:minecraft_compass/data/repositories/location_repository.dart';
import 'package:minecraft_compass/data/repositories/newsfeed_repository.dart';
import 'package:minecraft_compass/data/repositories/message_repository.dart';
import 'package:minecraft_compass/data/repositories/friend_repository.dart';
import 'package:minecraft_compass/data/services/cloudinary_service.dart';
import 'package:minecraft_compass/router/app_router.dart';
import 'package:minecraft_compass/config/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:minecraft_compass/presentation/locale/bloc/locale_bloc.dart';

class MinecraftCompassApp extends StatelessWidget {
  const MinecraftCompassApp({super.key});
  @override
  Widget build(BuildContext context) {
    // Tắt native splash screen sau khi app đã build xong
    FlutterNativeSplash.remove();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              AuthBloc(authRepository: getIt<AuthRepository>()),
        ),
        BlocProvider(
          create: (context) =>
              FriendBloc(friendRepository: getIt<FriendRepository>()),
        ),
        BlocProvider(
          create: (context) =>
              CompassBloc(locationRepository: getIt<LocationRepository>()),
        ),
        BlocProvider(
          create: (context) => ProfileBloc(
            auth: getIt<FirebaseAuth>(),
            userRepository: getIt<UserRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) =>
              ConversationBloc(messageRepository: getIt<MessageRepository>()),
        ),
        BlocProvider(
          create: (context) => NewsfeedBloc(
            newsfeedRepository: getIt<NewsfeedRepository>(),
            cloudinaryService: getIt<CloudinaryService>(),
            profileBloc: getIt<ProfileBloc>(),
          ),
        ),
        BlocProvider(
          create: (context) => MapBloc(
            authBloc: getIt<AuthBloc>(),
            friendBloc: getIt<FriendBloc>(),
            newsfeedBloc: getIt<NewsfeedBloc>(),
          ),
        ),
        BlocProvider(
          create: (context) =>
              getIt<LocaleBloc>()..add(const LocaleInitialized()),
        ),
      ],
      child: BlocBuilder<LocaleBloc, LocaleState>(
        builder: (context, localeState) {
          // Mặc định sử dụng tiếng Anh, sẽ được thay đổi khi LocaleBloc load xong
          Locale currentLocale = const Locale('en', 'US');

          if (localeState is LocaleLoaded) {
            currentLocale = localeState.locale;
          }

          return MaterialApp.router(
            title: 'Minecraft Compass',
            debugShowCheckedModeBanner: false,
            routerConfig: AppRouter.router(),
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            locale: currentLocale,
            // Localization configuration
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en', 'US'), Locale('vi', 'VN')],
          );
        },
      ),
    );
  }
}
