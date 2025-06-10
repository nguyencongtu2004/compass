enum MapDisplayMode {
  locations, // Chế độ hiển thị vị trí bạn bè và mình
  friends,   // Chế độ hiển thị feed posts từ bạn bè và mình
  explore,   // Chế độ khám phá posts xung quanh (không bao gồm bạn bè) và mình
}

extension MapDisplayModeExtension on MapDisplayMode {
  String get displayName {
    switch (this) {
      case MapDisplayMode.locations:
        return 'Friends';
      case MapDisplayMode.friends:
        return 'Feeds';
      case MapDisplayMode.explore:
        return 'Explore';
    }
  }

  String get description {
    switch (this) {
      case MapDisplayMode.locations:
        return 'Hiển thị vị trí bạn bè';
      case MapDisplayMode.friends:
        return 'Hiển thị feed posts từ bạn bè';
      case MapDisplayMode.explore:
        return 'Khám phá posts xung quanh';
    }
  }
}
