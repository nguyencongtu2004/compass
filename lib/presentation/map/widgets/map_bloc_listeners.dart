import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import '../../../models/user_model.dart';
import '../../../models/newsfeed_post_model.dart';
import '../../compass/bloc/compass_bloc.dart';
import '../../friend/bloc/friend_bloc.dart';
import '../../newfeed/bloc/newsfeed_bloc.dart';

class MapBlocListeners extends StatelessWidget {
  final Widget child;
  final Function(LatLng?) onLocationChanged;
  final Function(List<UserModel>) onFriendsChanged;
  final Function(List<NewsfeedPost>) onFeedPostsChanged;

  const MapBlocListeners({
    super.key,
    required this.child,
    required this.onLocationChanged,
    required this.onFriendsChanged,
    required this.onFeedPostsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CompassBloc, CompassState>(
          listener: (context, state) {
            if (state is CompassReady &&
                state.currentLat != null &&
                state.currentLng != null) {
              final newLocation = LatLng(state.currentLat!, state.currentLng!);
              onLocationChanged(newLocation);
            }
          },
        ),
        BlocListener<FriendBloc, FriendState>(
          listener: (context, state) {
            if (state is FriendAndRequestsLoadSuccess) {
              final friends = state.friends
                  .where(
                    (friend) =>
                        friend.currentLocation?.latitude != null &&
                        friend.currentLocation?.longitude != null,
                  )
                  .toList();
              onFriendsChanged(friends);
            }
          },
        ),
        BlocListener<NewsfeedBloc, NewsfeedState>(
          listener: (context, state) {
            if (state is PostsLoaded) {
              final feedPosts = state.posts
                  .where((post) => post.location != null)
                  .toList();
              onFeedPostsChanged(feedPosts);
            }
          },
        ),
      ],
      child: child,
    );
  }
}
