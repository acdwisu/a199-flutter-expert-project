import 'package:ditonton/common/exception.dart';
import 'package:ditonton/data/datasources/db/database_helper.dart';
import 'package:ditonton/data/models/movie_table.dart';
import 'package:ditonton/domain/entities/movie_category.dart';

abstract class MovieLocalDataSource {
  Future<String> insertWatchlist(MovieTable movie);
  Future<String> removeWatchlist(MovieTable movie);
  Future<MovieTable?> getMovieById(int id);
  Future<List<MovieTable>> getWatchlistMovies();
  Future<void> cacheNowPlayingMovies(List<MovieTable> movies);
  Future<List<MovieTable>> getCachedNowPlayingMovies();
}

class MovieLocalDataSourceImpl implements MovieLocalDataSource {
  final DatabaseHelper databaseHelper;

  MovieLocalDataSourceImpl({required this.databaseHelper});

  @override
  Future<String> insertWatchlist(MovieTable movie) async {
    try {
      await databaseHelper.insertWatchlist(movie);
      return 'Added to Watchlist';
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<String> removeWatchlist(MovieTable movie) async {
    try {
      await databaseHelper.removeWatchlist(movie);
      return 'Removed from Watchlist';
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<MovieTable?> getMovieById(int id) async {
    final result = await databaseHelper.getMovieById(id);
    if (result != null) {
      return MovieTable.fromMap(result);
    } else {
      return null;
    }
  }

  @override
  Future<List<MovieTable>> getWatchlistMovies() async {
    final result = await databaseHelper.getWatchlistMovies();
    return result.map((data) => MovieTable.fromMap(data)).toList();
  }

  @override
  Future<void> cacheNowPlayingMovies(List<MovieTable> movies) async {
    try {
      final category = MovieCategory.NowPlaying;

      await databaseHelper.clearCacheMovies(category);
      await databaseHelper.insertCacheMovies(movies, category);
    } catch (e) {
      throw DatabaseException(e.toString());
    }
  }

  @override
  Future<List<MovieTable>> getCachedNowPlayingMovies() async {
    final result = await databaseHelper.getCachedMovies(MovieCategory.NowPlaying);

    if(result.length <= 0) {
      throw CacheException('No Cached Data');
    }

    return result.map((e) => MovieTable.fromMap(e)).toList();
  }
}
