part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

final class ProfileLoadRequested extends ProfileEvent {
  final bool showLoading;

  const ProfileLoadRequested({this.showLoading = true});

  @override
  List<Object> get props => [showLoading];
}

final class ProfileUpdateRequested extends ProfileEvent {
  final String? displayName;
  final String? username;
  final File? avatarFile;
  final bool isAvatarRemoved;

  const ProfileUpdateRequested({
    this.displayName,
    this.username,
    this.avatarFile,
    this.isAvatarRemoved = false,
  });

  @override
  List<Object> get props => [
    displayName ?? '',
    username ?? '',
    avatarFile?.path ?? '',
    isAvatarRemoved,
  ];
}

final class UsernameAvailabilityCheck extends ProfileEvent {
  final String username;

  const UsernameAvailabilityCheck(this.username);

  @override
  List<Object> get props => [username];
}

final class ProfileResetRequested extends ProfileEvent {
  const ProfileResetRequested();
}
