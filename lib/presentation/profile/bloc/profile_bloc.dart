import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../models/user_model.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository _userRepository;
  final FirebaseAuth _auth;

  ProfileBloc({UserRepository? userRepository, FirebaseAuth? auth})
    : _userRepository = userRepository ?? UserRepository(),
      _auth = auth ?? FirebaseAuth.instance,
      super(ProfileInitial()) {
    on<ProfileLoadRequested>(_onProfileLoadRequested);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
    on<UsernameAvailabilityCheck>(_onUsernameAvailabilityCheck);
  }

  void _onProfileLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final user = await _userRepository.getUserByUid(currentUser.uid);
        if (user != null) {
          emit(ProfileLoaded(user));
        } else {
          emit(const ProfileError('Không tìm thấy thông tin người dùng'));
        }
      } else {
        emit(const ProfileError('Người dùng chưa đăng nhập'));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  void _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileUpdateLoading());
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _userRepository.updateProfile(
          uid: currentUser.uid,
          displayName: event.displayName,
          username: event.username,
          avatarFile: event.avatarFile,
        );
        emit(ProfileUpdateSuccess());
        // Reload profile after update
        add(const ProfileLoadRequested());
      } else {
        emit(const ProfileError('Người dùng chưa đăng nhập'));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  void _onUsernameAvailabilityCheck(
    UsernameAvailabilityCheck event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final isAvailable = await _userRepository.isUsernameAvailable(
        event.username,
      );
      emit(UsernameAvailable(isAvailable));
    } catch (e) {
      emit(UsernameAvailable(false));
    }
  }
}
