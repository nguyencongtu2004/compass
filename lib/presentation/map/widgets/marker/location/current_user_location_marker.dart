import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minecraft_compass/presentation/core/theme/app_colors.dart';
import 'package:minecraft_compass/presentation/core/widgets/common_avatar.dart';
import 'package:minecraft_compass/presentation/profile/bloc/profile_bloc.dart';

class CurrentUserLocationMarker extends StatelessWidget {
  const CurrentUserLocationMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, profileState) => profileState is ProfileLoaded
          ? CommonAvatar(
              radius: 25,
              avatarUrl: profileState.user.avatarUrl,
              displayName: profileState.user.displayName,
              borderSpacing: 0,
              borderColor: AppColors.primary(context),
            )
          : const CommonAvatar(radius: 25),
    );
  }
}
