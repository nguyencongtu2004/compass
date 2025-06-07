part of 'profile_bloc.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

final class ProfileLoaded extends ProfileState {
  final UserModel user;

  const ProfileLoaded(this.user);

  @override
  List<Object> get props => [user];
}

final class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object> get props => [message];
}

final class ProfileUpdateSuccess extends ProfileState {}

final class ProfileUpdateLoading extends ProfileState {}

final class UsernameAvailable extends ProfileState {
  final bool isAvailable;

  const UsernameAvailable(this.isAvailable);

  @override
  List<Object> get props => [isAvailable];
}
