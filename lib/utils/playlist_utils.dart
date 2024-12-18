class PlaylistUtils {
  static String getDisplayName(String? name) {
    switch (name) {
      case '__SYS_PLAYLIST_MARKED':
        return '我标记的';
      case '__SYS_PLAYLIST_LIKED':
        return '我喜欢的';
      default:
        return name ?? '';
    }
  }
} 