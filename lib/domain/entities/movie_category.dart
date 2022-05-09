enum MovieCategory {
  NowPlaying,
}

extension MovieCategoriesConverter on MovieCategory {
  String get inString {
    switch(this) {
      case MovieCategory.NowPlaying:
        return 'Now Playing';
      default:
        return '-';
    }
  }
}