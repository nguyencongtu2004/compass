part of 'newsfeed_bloc.dart';

abstract class NewsfeedEvent extends Equatable {
  const NewsfeedEvent();

  @override
  List<Object?> get props => [];
}

class LoadPosts extends NewsfeedEvent {
  const LoadPosts();
}

class CreatePost extends NewsfeedEvent {
  final File imageFile;
  final String? caption;
  final LocationModel? location;

  const CreatePost({required this.imageFile, this.caption, this.location});

  @override
  List<Object?> get props => [imageFile, caption, location];
}

class RefreshPosts extends NewsfeedEvent {
  const RefreshPosts();
}

class LoadMorePosts extends NewsfeedEvent {
  const LoadMorePosts();
}

class DeletePost extends NewsfeedEvent {
  final String postId;

  const DeletePost({required this.postId});

  @override
  List<Object?> get props => [postId];
}

class NewsfeedResetRequested extends NewsfeedEvent {
  const NewsfeedResetRequested();
}

class LoadPostsByLocation extends NewsfeedEvent {
  final double currentLat;
  final double currentLng;
  final double radiusInMeters;
  final List<String>? excludeFriendUids;
  final String? currentUserId;

  const LoadPostsByLocation({
    required this.currentLat,
    required this.currentLng,
    required this.radiusInMeters,
    this.excludeFriendUids,
    this.currentUserId,
  });

  @override
  List<Object?> get props => [
    currentLat,
    currentLng,
    radiusInMeters,
    excludeFriendUids,
    currentUserId,
  ];
}

class LoadPostsFromFriends extends NewsfeedEvent {
  final List<String> friendUids;

  const LoadPostsFromFriends({required this.friendUids});

  @override
  List<Object?> get props => [friendUids];
}

class LoadFriendPosts extends NewsfeedEvent {
  final String currentUserId;
  final List<String> friendUids;

  const LoadFriendPosts({
    required this.currentUserId,
    required this.friendUids,
  });

  @override
  List<Object?> get props => [currentUserId, friendUids];
}

// Event để load posts từ mình và bạn bè (tương thích với MapBloc)
class LoadFeedPosts extends NewsfeedEvent {
  final String currentUserId;
  final List<String> friendUids;

  const LoadFeedPosts({required this.currentUserId, required this.friendUids});

  @override
  List<Object?> get props => [currentUserId, friendUids];
}
