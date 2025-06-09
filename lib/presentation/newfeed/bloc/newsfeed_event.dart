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