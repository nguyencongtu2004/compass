import 'package:equatable/equatable.dart';
import 'package:minecraft_compass/utils/prase_utils.dart';
import 'location_model.dart';

class UserModel extends Equatable {
  final String uid;
  final String displayName;
  final String username;
  final String email;
  final String avatarUrl;
  final DateTime createdAt;
  final LocationModel? currentLocation;
  final List<String> friends;
  final List<String> friendRequests;

  const UserModel({
    required this.uid,
    required this.displayName,
    required this.username,
    required this.email,
    required this.avatarUrl,
    required this.createdAt,
    this.currentLocation,
    required this.friends,
    required this.friendRequests,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      displayName: map['displayName'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      createdAt: PraseUtils.parseDateTime(map['createdAt']),
      currentLocation: map['currentLocation'] != null
          ? LocationModel.fromMap(
              map['currentLocation'] as Map<String, dynamic>,
            )
          : null,
      friends: List<String>.from(map['friends'] ?? []),
      friendRequests: List<String>.from(map['friendRequests'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'username': username,
      'email': email,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt,
      'currentLocation': currentLocation?.toMap(),
      'friends': friends,
      'friendRequests': friendRequests,
    };
  }

  UserModel copyWith({
    String? displayName,
    String? username,
    String? email,
    String? avatarUrl,
    DateTime? createdAt,
    LocationModel? currentLocation,
    List<String>? friends,
    List<String>? friendRequests,
  }) {
    return UserModel(
      uid: uid,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      currentLocation: currentLocation ?? this.currentLocation,
      friends: friends ?? this.friends,
      friendRequests: friendRequests ?? this.friendRequests,
    );
  }

  @override
  List<Object?> get props => [
    uid,
    displayName,
    username,
    email,
    avatarUrl,
    createdAt,
    currentLocation,
    friends,
    friendRequests,
  ];
}
