part of 'newsfeed_bloc.dart';

abstract class NewsfeedState extends Equatable {
  const NewsfeedState();

  @override
  List<Object?> get props => [];
}

class NewsfeedInitial extends NewsfeedState {}

class NewsfeedLoading extends NewsfeedState {}

class PostsLoaded extends NewsfeedState {
  final List<NewsfeedPost> posts;
  final bool hasMorePosts;

  const PostsLoaded({required this.posts, this.hasMorePosts = true});

  @override
  List<Object?> get props => [posts, hasMorePosts];
}

class CreatingPost extends NewsfeedState {}

class PostCreated extends NewsfeedState {}

class NewsfeedError extends NewsfeedState {
  final String message;

  const NewsfeedError({required this.message});

  @override
  List<Object?> get props => [message];
}
