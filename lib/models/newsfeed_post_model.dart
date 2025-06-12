import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'location_model.dart';

class NewsfeedPost extends Equatable {
  final String id;
  final String userId;
  final String userDisplayName;
  final String? userAvatarUrl;
  final String imageUrl;
  final String? caption;
  final DateTime createdAt;
  final LocationModel? location;

  const NewsfeedPost({
    required this.id,
    required this.userId,
    required this.userDisplayName,
    this.userAvatarUrl,
    required this.imageUrl,
    this.caption,
    required this.createdAt,
    this.location,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userDisplayName': userDisplayName,
      'userAvatarUrl': userAvatarUrl,
      'imageUrl': imageUrl,
      'caption': caption,
      'createdAt': Timestamp.fromDate(createdAt),
      'location': location?.toMap(),
    };
  }

  factory NewsfeedPost.fromMap(String id, Map<String, dynamic> map) {
    return NewsfeedPost(
      id: id,
      userId: map['userId'] ?? '',
      userDisplayName: map['userDisplayName'] ?? '',
      userAvatarUrl: map['userAvatarUrl'],
      imageUrl: map['imageUrl'] ?? '',
      caption: map['caption'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      location: map['location'] != null
          ? LocationModel.fromMap(map['location'] as Map<String, dynamic>)
          : null,
    );
  }

  NewsfeedPost copyWith({
    String? id,
    String? userId,
    String? userDisplayName,
    String? userAvatarUrl,
    String? imageUrl,
    String? caption,
    DateTime? createdAt,
    LocationModel? location,
  }) {
    return NewsfeedPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
      location: location ?? this.location,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        userDisplayName,
        userAvatarUrl,
        imageUrl,
        caption,
        createdAt,
        location,
      ];
}
