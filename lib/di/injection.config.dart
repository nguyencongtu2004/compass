// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:get_it/get_it.dart' as _i174;
import 'package:google_sign_in/google_sign_in.dart' as _i116;
import 'package:injectable/injectable.dart' as _i526;
import 'package:minecraft_compass/data/managers/message_bloc_manager.dart'
    as _i961;
import 'package:minecraft_compass/data/repositories/auth_repository.dart'
    as _i41;
import 'package:minecraft_compass/data/repositories/friend_repository.dart'
    as _i753;
import 'package:minecraft_compass/data/repositories/location_repository.dart'
    as _i276;
import 'package:minecraft_compass/data/repositories/message_repository.dart'
    as _i125;
import 'package:minecraft_compass/data/repositories/newsfeed_repository.dart'
    as _i426;
import 'package:minecraft_compass/data/repositories/user_repository.dart'
    as _i194;
import 'package:minecraft_compass/data/services/cloudinary_service.dart'
    as _i990;
import 'package:minecraft_compass/data/services/http_service.dart';
import 'package:minecraft_compass/di/injection.dart' as _i642;
import 'package:minecraft_compass/presentation/auth/bloc/auth_bloc.dart'
    as _i1021;
import 'package:minecraft_compass/presentation/compass/bloc/compass_bloc.dart'
    as _i174;
import 'package:minecraft_compass/presentation/friend/bloc/friend_bloc.dart'
    as _i913;
import 'package:minecraft_compass/presentation/map/bloc/map_bloc.dart'
    as _i1027;
import 'package:minecraft_compass/presentation/messaging/conversation/bloc/conversation_bloc.dart'
    as _i260;
import 'package:minecraft_compass/presentation/newfeed/bloc/newsfeed_bloc.dart'
    as _i907;
import 'package:minecraft_compass/presentation/profile/bloc/profile_bloc.dart'
    as _i471;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final firebaseInjectableModule = _$FirebaseInjectableModule();
    gh.singleton<_i59.FirebaseAuth>(
      () => firebaseInjectableModule.firebaseAuth,
    );
    gh.singleton<_i974.FirebaseFirestore>(
      () => firebaseInjectableModule.firestore,
    );
    gh.singleton<_i116.GoogleSignIn>(
      () => firebaseInjectableModule.googleSignIn,
    );
    gh.lazySingleton<_i990.CloudinaryService>(() => _i990.CloudinaryService());
    gh.lazySingleton<HttpService>(() => HttpService());
    gh.lazySingleton<_i753.FriendRepository>(
      () => _i753.FriendRepository(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i276.LocationRepository>(
      () => _i276.LocationRepository(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i125.MessageRepository>(
      () => _i125.MessageRepository(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i426.NewsfeedRepository>(
      () => _i426.NewsfeedRepository(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i174.CompassBloc>(
      () =>
          _i174.CompassBloc(locationRepository: gh<_i276.LocationRepository>()),
    );
    gh.lazySingleton<_i194.UserRepository>(
      () => _i194.UserRepository(
        gh<_i990.CloudinaryService>(),
        gh<_i974.FirebaseFirestore>(),
      ),
    );
    gh.lazySingleton<_i913.FriendBloc>(
      () => _i913.FriendBloc(friendRepository: gh<_i753.FriendRepository>()),
    );
    gh.lazySingleton<_i471.ProfileBloc>(
      () => _i471.ProfileBloc(
        userRepository: gh<_i194.UserRepository>(),
        auth: gh<_i59.FirebaseAuth>(),
      ),
    );
    gh.lazySingleton<_i41.AuthRepository>(
      () => _i41.AuthRepository(
        firebaseAuth: gh<_i59.FirebaseAuth>(),
        firestore: gh<_i974.FirebaseFirestore>(),
        googleSignIn: gh<_i116.GoogleSignIn>(),
      ),
    );
    gh.lazySingleton<_i1021.AuthBloc>(
      () => _i1021.AuthBloc(authRepository: gh<_i41.AuthRepository>()),
    );
    gh.singleton<_i961.MessageBlocManager>(
      () => _i961.MessageBlocManager(
        messageRepository: gh<_i125.MessageRepository>(),
      ),
    );
    gh.lazySingleton<_i260.ConversationBloc>(
      () => _i260.ConversationBloc(
        messageRepository: gh<_i125.MessageRepository>(),
      ),
    );
    gh.lazySingleton<_i907.NewsfeedBloc>(
      () => _i907.NewsfeedBloc(
        newsfeedRepository: gh<_i426.NewsfeedRepository>(),
        cloudinaryService: gh<_i990.CloudinaryService>(),
        profileBloc: gh<_i471.ProfileBloc>(),
      ),
    );
    gh.lazySingleton<_i1027.MapBloc>(
      () => _i1027.MapBloc(
        authBloc: gh<_i1021.AuthBloc>(),
        friendBloc: gh<_i913.FriendBloc>(),
        newsfeedBloc: gh<_i907.NewsfeedBloc>(),
      ),
    );
    return this;
  }
}

class _$FirebaseInjectableModule extends _i642.FirebaseInjectableModule {}
