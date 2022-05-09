import 'dart:async';

import 'package:ditonton/data/models/movie_table.dart';
import 'package:ditonton/domain/entities/movie_category.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper;
  DatabaseHelper._instance() {
    _databaseHelper = this;
  }

  factory DatabaseHelper() => _databaseHelper ?? DatabaseHelper._instance();

  static Database? _database;

  Future<Database?> get database async {
    if (_database == null) {
      _database = await _initDb();
    }
    return _database;
  }

  static const String _tblWatchlistMovies = 'watchlist-movies';
  static const String _tblCacheMovies = 'cache-movies';

  Future<Database> _initDb() async {
    final path = await getDatabasesPath();
    final databasePath = '$path/ditonton.db';

    var db = await openDatabase(databasePath, version: 1, onCreate: _onCreate);
    return db;
  }

  void _onCreate(Database db, int version) async {
    await Future.wait([
      db.execute(
        '''
          CREATE TABLE  $_tblWatchlistMovies (
            id INTEGER PRIMARY KEY,
            title TEXT,
            overview TEXT,
            posterPath TEXT
          );
        '''
      ),
      db.execute(
        '''
          CREATE TABLE  $_tblCacheMovies (
            id INTEGER,
            title TEXT,
            overview TEXT,
            posterPath TEXT,
            category TEXT,
            idCache INTEGER PRIMARY KEY AUTOINCREMENT
          );
        '''
      ),
    ]);
  }

  Future<int> insertWatchlist(MovieTable movie) async {
    final db = await database;
    return await db!.insert(_tblWatchlistMovies, movie.toJson());
  }

  Future<int> removeWatchlist(MovieTable movie) async {
    final db = await database;
    return await db!.delete(
      _tblWatchlistMovies,
      where: 'id = ?',
      whereArgs: [movie.id],
    );
  }

  Future<Map<String, dynamic>?> getMovieById(int id) async {
    final db = await database;
    final results = await db!.query(
      _tblWatchlistMovies,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isNotEmpty) {
      return results.first;
    } else {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getWatchlistMovies() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db!.query(_tblWatchlistMovies);

    return results;
  }

  Future<void> insertCacheMovies(List<MovieTable> movies, MovieCategory category) async {
    final db = _database ?? await database;

    await db!.transaction((txn) async {
      final batch = txn.batch();

      movies.forEach((e) {
        batch.insert(_tblCacheMovies, e.toJson()
          ..putIfAbsent('category', () => category.inString));
      });

      batch.commit();
    });
  }

  Future<int> clearCacheMovies(MovieCategory category) async {
    final db = await database;

    return await db!.delete(
      _tblCacheMovies,
      where: 'category = ?',
      whereArgs: [category.inString]
    );
  }

  Future<List<Map<String, dynamic>>> getCachedMovies(MovieCategory category) async {
    final db = await database;

    final List<Map<String, dynamic>> results = await db!.query(
        _tblCacheMovies,
      where: 'category = ?',
      whereArgs: [category.inString],
    );

    return results;
  }
}
