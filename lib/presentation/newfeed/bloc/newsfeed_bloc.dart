import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/newsfeed_post_model.dart';
import '../../../models/location_model.dart';
import '../../../data/repositories/newsfeed_repository.dart';
import '../../../data/services/cloudinary_service.dart';
import '../../profile/bloc/profile_bloc.dart';

part 'newsfeed_event.dart';
part 'newsfeed_state.dart';

class NewsfeedBloc extends Bloc<NewsfeedEvent, NewsfeedState> {
  final NewsfeedRepository _newsfeedRepository;
  final CloudinaryService _cloudinaryService;
  final ProfileBloc _profileBloc;

  // Pagination properties
  List<NewsfeedPost> _allPosts = [];
  bool _hasMorePosts = true;

  NewsfeedBloc({
    NewsfeedRepository? newsfeedRepository,
    CloudinaryService? cloudinaryService,
    required ProfileBloc profileBloc,
  }) : _newsfeedRepository = newsfeedRepository ?? NewsfeedRepository(),
       _cloudinaryService = cloudinaryService ?? CloudinaryService(),
       _profileBloc = profileBloc,
       super(NewsfeedInitial()) {
    on<LoadPosts>(_onLoadPosts);
    on<CreatePost>(_onCreatePost);
    on<RefreshPosts>(_onRefreshPosts);
    on<LoadMorePosts>(_onLoadMorePosts);
    on<DeletePost>(_onDeletePost);
    on<NewsfeedResetRequested>(_onNewsfeedResetRequested);
  }
  void _onLoadPosts(LoadPosts event, Emitter<NewsfeedState> emit) async {
    emit(NewsfeedLoading());
    try {
      // Reset pagination
      _allPosts.clear();
      _hasMorePosts = true;

      // Load first 3 posts
      final posts = await _newsfeedRepository.getPosts(limit: 3);
      _allPosts = List.from(posts);
      _hasMorePosts =
          posts.length == 3; // Assume more posts if we got the full limit

      emit(
        PostsLoaded(posts: List.from(_allPosts), hasMorePosts: _hasMorePosts),
      );
    } catch (e) {
      emit(NewsfeedError(message: e.toString()));
    }
  }

  void _onCreatePost(CreatePost event, Emitter<NewsfeedState> emit) async {
    try {
      emit(CreatingPost());

      // Get current user from ProfileBloc
      final profileState = _profileBloc.state;
      if (profileState is! ProfileLoaded) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      final user = profileState.user;

      // Upload image to Cloudinary
      final imageUrl = await _cloudinaryService.uploadUserImage(
        event.imageFile,
        user.uid,
      );

      if (imageUrl == null) {
        throw Exception('Không thể upload ảnh');
      }

      // Create post object
      final post = NewsfeedPost(
        id: '', // Will be set by Firestore
        userId: user.uid,
        userDisplayName: user.displayName,
        userAvatarUrl: user.avatarUrl.isNotEmpty ? user.avatarUrl : null,
        imageUrl: imageUrl,
        caption: event.caption,
        createdAt: DateTime.now(),
        location: event.location,
      );

      // Save to Firestore
      await _newsfeedRepository.createPost(post);

      emit(PostCreated());

      // Reload posts to show the new one
      add(const LoadPosts());
    } catch (e) {
      emit(NewsfeedError(message: e.toString()));
    }
  }

  void _onRefreshPosts(RefreshPosts event, Emitter<NewsfeedState> emit) async {
    try {
      // Reset pagination
      _allPosts.clear();
      _hasMorePosts = true;

      // Load first 3 posts
      final posts = await _newsfeedRepository.getPosts(limit: 3);
      _allPosts = List.from(posts);
      _hasMorePosts = posts.length == 3;

      emit(
        PostsLoaded(posts: List.from(_allPosts), hasMorePosts: _hasMorePosts),
      );
    } catch (e) {
      emit(NewsfeedError(message: e.toString()));
    }
  }

  void _onLoadMorePosts(
    LoadMorePosts event,
    Emitter<NewsfeedState> emit,
  ) async {
    try {
      // Don't load if we're already at the end
      if (!_hasMorePosts) return;

      // Get the current state to avoid loading if we're already loading
      if (state is NewsfeedLoading) return;

      // Load 1 more post using skip offset
      final newPosts = await _newsfeedRepository.getPostsWithOffset(
        limit: 1,
        offset: _allPosts.length,
      );

      if (newPosts.isNotEmpty) {
        _allPosts.addAll(newPosts);
        _hasMorePosts =
            newPosts.length == 1; // Still more if we got what we asked for
      } else {
        _hasMorePosts = false; // No more posts available
      }

      emit(
        PostsLoaded(posts: List.from(_allPosts), hasMorePosts: _hasMorePosts),
      );
    } catch (e) {
      emit(NewsfeedError(message: e.toString()));
    }
  }

  void _onDeletePost(DeletePost event, Emitter<NewsfeedState> emit) async {
    try {
      await _newsfeedRepository.deletePost(event.postId);
      // Remove from local list and reload to get fresh data
      _allPosts.removeWhere((post) => post.id == event.postId);
      add(const LoadPosts()); // Reload posts to refresh pagination
    } catch (e) {
      emit(NewsfeedError(message: e.toString()));
    }
  }

  void _onNewsfeedResetRequested(
    NewsfeedResetRequested event,
    Emitter<NewsfeedState> emit,
  ) {
    _allPosts.clear();
    _hasMorePosts = true;
    emit(NewsfeedInitial());
  }
}
