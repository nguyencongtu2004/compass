part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

final class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

final class ProfileUpdateRequested extends ProfileEvent {
  final String? displayName;
  final String? username;
  final File? avatarFile;

  const ProfileUpdateRequested({
    this.displayName,
    this.username,
    this.avatarFile,
  });

  @override
  List<Object> get props => [
    displayName ?? '',
    username ?? '',
    avatarFile?.path ?? '',
  ];
}

final class UsernameAvailabilityCheck extends ProfileEvent {
  final String username;

  const UsernameAvailabilityCheck(this.username);

  @override
  List<Object> get props => [username];
}
