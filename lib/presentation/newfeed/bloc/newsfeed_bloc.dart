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

// Enum để track loại posts hiện tại - chỉ có 2 loại tương ứng với chế độ map
enum PostType { friends, explore }

class NewsfeedBloc extends Bloc<NewsfeedEvent, NewsfeedState> {
  final NewsfeedRepository _newsfeedRepository;
  final CloudinaryService _cloudinaryService;
  final ProfileBloc _profileBloc;
  
  // Chỉ lưu 2 loại posts tương ứng với 2 chế độ map
  List<NewsfeedPost> _friendsPosts =
      []; // Posts từ mình và bạn bè (MapDisplayMode.friends)
  List<NewsfeedPost> _explorePosts =
      []; // Posts từ mình và người lạ (MapDisplayMode.explore)

  bool _hasMoreFriendsPosts = true;
  bool _hasMoreExplorePosts = true;

  // Track loại posts hiện tại đang hiển thị
  PostType _currentPostType = PostType.friends;

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
    on<LoadPostsByLocation>(_onLoadPostsByLocation);
    on<LoadPostsFromFriends>(_onLoadPostsFromFriends);
    on<LoadFriendPosts>(_onLoadFriendPosts);
    on<LoadFeedPosts>(_onLoadFeedPosts);
  }

  void _onLoadPosts(LoadPosts event, Emitter<NewsfeedState> emit) async {
    emit(NewsfeedLoading());
    try {
      // Load posts từ mình và bạn bè (mặc định)
      _currentPostType = PostType.friends;
      _friendsPosts.clear();
      _hasMoreFriendsPosts = true;

      // TODO: Load friends posts - cần có currentUserId và friendUids
      emit(
        PostsLoaded(
          posts: List.from(_friendsPosts),
          hasMorePosts: _hasMoreFriendsPosts,
        ),
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

      // Reload posts dựa vào loại hiện tại để hiển thị post mới
      switch (_currentPostType) {
        case PostType.friends:
          // Post mới của mình sẽ hiện trong friends posts
          // TODO: Reload friends posts
          break;
        case PostType.explore:
          // Post mới của mình cũng có thể hiện trong explore posts
          // TODO: Reload explore posts nếu location khớp
          break;
      }
    } catch (e) {
      emit(NewsfeedError(message: e.toString()));
    }
  }

  void _onRefreshPosts(RefreshPosts event, Emitter<NewsfeedState> emit) async {
    try {
      // Refresh dựa vào loại posts hiện tại
      switch (_currentPostType) {
        case PostType.friends:
          _friendsPosts.clear();
          _hasMoreFriendsPosts = true;
          
          // TODO: Reload friends posts
          emit(
            PostsLoaded(
              posts: List.from(_friendsPosts),
              hasMorePosts: _hasMoreFriendsPosts,
            ),
          );
          break;

        case PostType.explore:
          _explorePosts.clear();
          _hasMoreExplorePosts = true;

          // TODO: Reload explore posts
          emit(
            PostsLoaded(
              posts: List.from(_explorePosts),
              hasMorePosts: _hasMoreExplorePosts,
            ),
          );
          break;
      }
    } catch (e) {
      emit(NewsfeedError(message: e.toString()));
    }
  }

  void _onLoadMorePosts(
    LoadMorePosts event,
    Emitter<NewsfeedState> emit,
  ) async {
    try {
      // Tránh load khi đang loading
      if (state is NewsfeedLoading) return;

      // Load more posts dựa vào loại hiện tại
      switch (_currentPostType) {
        case PostType.friends:
          if (!_hasMoreFriendsPosts) return;

          // TODO: Implement load more for friends posts with pagination
          _hasMoreFriendsPosts = false;
          emit(
            PostsLoaded(
              posts: List.from(_friendsPosts),
              hasMorePosts: _hasMoreFriendsPosts,
            ),
          );
          break;

        case PostType.explore:
          if (!_hasMoreExplorePosts) return;

          // TODO: Implement load more for explore posts with pagination
          _hasMoreExplorePosts = false;
          emit(
            PostsLoaded(
              posts: List.from(_explorePosts),
              hasMorePosts: _hasMoreExplorePosts,
            ),
          );
          break;
      }
    } catch (e) {
      emit(NewsfeedError(message: e.toString()));
    }
  }

  void _onDeletePost(DeletePost event, Emitter<NewsfeedState> emit) async {
    try {
      await _newsfeedRepository.deletePost(event.postId);

      // Remove từ cả 2 danh sách
      _friendsPosts.removeWhere((post) => post.id == event.postId);
      _explorePosts.removeWhere((post) => post.id == event.postId);

      // Emit updated list dựa vào loại hiện tại
      switch (_currentPostType) {
        case PostType.friends:
          emit(
            PostsLoaded(
              posts: List.from(_friendsPosts),
              hasMorePosts: _hasMoreFriendsPosts,
            ),
          );
          break;
        case PostType.explore:
          emit(
            PostsLoaded(
              posts: List.from(_explorePosts),
              hasMorePosts: _hasMoreExplorePosts,
            ),
          );
          break;
      }
    } catch (e) {
      emit(NewsfeedError(message: e.toString()));
    }
  }

  void _onNewsfeedResetRequested(
    NewsfeedResetRequested event,
    Emitter<NewsfeedState> emit,
  ) {
    // Reset tất cả các biến lưu trữ posts
    _friendsPosts.clear();
    _explorePosts.clear();

    // Reset tất cả các biến pagination
    _hasMoreFriendsPosts = true;
    _hasMoreExplorePosts = true;

    emit(NewsfeedInitial());
  }

  void _onLoadPostsByLocation(
    LoadPostsByLocation event,
    Emitter<NewsfeedState> emit,
  ) async {
    emit(NewsfeedLoading());
    try {
      // Reset pagination cho explore posts
      _explorePosts.clear();
      _hasMoreExplorePosts = true;
      _currentPostType = PostType.explore;

      final posts = await _newsfeedRepository.getPostsByLocation(
        currentLat: event.currentLat,
        currentLng: event.currentLng,
        radiusInMeters: event.radiusInMeters,
        excludeFriendUids: event.excludeFriendUids,
        currentUserId: event.currentUserId,
        limit: 10,
      );

      _explorePosts = List.from(posts);
      _hasMoreExplorePosts = posts.length == 10;

      emit(
        PostsLoaded(
          posts: List.from(_explorePosts),
          hasMorePosts: _hasMoreExplorePosts,
        ),
      );
    } catch (e) {
      emit(NewsfeedError(message: e.toString()));
    }
  }

  void _onLoadPostsFromFriends(
    LoadPostsFromFriends event,
    Emitter<NewsfeedState> emit,
  ) async {
    emit(NewsfeedLoading());
    try {
      // Reset pagination cho friends posts
      _friendsPosts.clear();
      _hasMoreFriendsPosts = true;
      _currentPostType = PostType.friends;

      final posts = await _newsfeedRepository.getPostsFromFriends(
        friendUids: event.friendUids,
        limit: 10,
      );

      _friendsPosts = List.from(posts);
      _hasMoreFriendsPosts = posts.length == 10;

      emit(
        PostsLoaded(
          posts: List.from(_friendsPosts),
          hasMorePosts: _hasMoreFriendsPosts,
        ),
      );
    } catch (e) {
      emit(NewsfeedError(message: e.toString()));
    }
  }
  void _onLoadFriendPosts(
    LoadFriendPosts event,
    Emitter<NewsfeedState> emit,
  ) async {
    emit(NewsfeedLoading());
    try {
      // Reset pagination cho friends posts
      _friendsPosts.clear();
      _hasMoreFriendsPosts = true;
      _currentPostType = PostType.friends;

      final posts = await _newsfeedRepository.getPostsFromSelfAndFriends(
        currentUserId: event.currentUserId,
        friendUids: event.friendUids,
        limit: 10,
      );

      _friendsPosts = List.from(posts);
      _hasMoreFriendsPosts = posts.length == 10;

      emit(
        PostsLoaded(
          posts: List.from(_friendsPosts),
          hasMorePosts: _hasMoreFriendsPosts,
        ),
      );
    } catch (e) {
      emit(NewsfeedError(message: e.toString()));
    }
  }
  // Handler cho LoadFeedPosts (alias cho LoadFriendPosts để tương thích với MapBloc)
  void _onLoadFeedPosts(
    LoadFeedPosts event,
    Emitter<NewsfeedState> emit,
  ) async {
    // Gọi cùng logic với _onLoadFriendPosts
    _onLoadFriendPosts(
      LoadFriendPosts(
        currentUserId: event.currentUserId,
        friendUids: event.friendUids,
      ),
      emit,
    );
  }
}
