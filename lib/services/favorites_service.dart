/// Service for managing favorite movies in the Movie Star application.
///
// Time-stamp: <Thursday 2025-04-10 11:47:48 +1000 Graham Williams>
///
/// Copyright (C) 2025, Software Innovation Institute, ANU.
///
/// Licensed under the GNU General Public License, Version 3 (the "License").
///
/// License: https://www.gnu.org/licenses/gpl-3.0.en.html.
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <https://www.gnu.org/licenses/>.
///
/// Authors: Kevin Wang

library;

import 'dart:convert';

import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/movie.dart';

/// A service class that manages the user's movie lists.

class FavoritesService {
  /// Key used to store to-watch movies in shared preferences.

  static const String _toWatchKey = 'to_watch';

  /// Key used to store watched movies in shared preferences.

  static const String _watchedKey = 'watched';

  /// Shared preferences instance for storing movie lists.

  final SharedPreferences _prefs;

  /// Stream controller for to-watch movies.

  final _toWatchController = BehaviorSubject<List<Movie>>();

  /// Stream controller for watched movies.

  final _watchedController = BehaviorSubject<List<Movie>>();

  /// Stream of to-watch movies.

  Stream<List<Movie>> get toWatchMovies => _toWatchController.stream;

  /// Stream of watched movies.

  Stream<List<Movie>> get watchedMovies => _watchedController.stream;

  /// Creates a new [FavoritesService] instance.

  FavoritesService(this._prefs) {
    _loadMovies();
  }

  /// Loads both movie lists and emits them to their respective streams.

  Future<void> _loadMovies() async {
    final toWatch = await getToWatch();
    final watched = await getWatched();
    _toWatchController.add(toWatch);
    _watchedController.add(watched);
  }

  /// Retrieves the list of to-watch movies.

  Future<List<Movie>> getToWatch() async {
    final String? moviesJson = _prefs.getString(_toWatchKey);
    if (moviesJson == null) return [];

    final List<dynamic> decoded = jsonDecode(moviesJson);
    return decoded.map((movie) => Movie.fromJson(movie)).toList();
  }

  /// Retrieves the list of watched movies.

  Future<List<Movie>> getWatched() async {
    final String? moviesJson = _prefs.getString(_watchedKey);
    if (moviesJson == null) return [];

    final List<dynamic> decoded = jsonDecode(moviesJson);
    return decoded.map((movie) => Movie.fromJson(movie)).toList();
  }

  /// Adds a movie to the to-watch list.

  Future<void> addToWatch(Movie movie) async {
    final toWatch = await getToWatch();
    if (!toWatch.any((m) => m.id == movie.id)) {
      toWatch.add(movie);
      await _saveToWatch(toWatch);
      _toWatchController.add(toWatch);
    }
  }

  /// Adds a movie to the watched list.

  Future<void> addToWatched(Movie movie) async {
    final watched = await getWatched();
    if (!watched.any((m) => m.id == movie.id)) {
      watched.add(movie);
      await _saveWatched(watched);
      _watchedController.add(watched);
    }
  }

  /// Removes a movie from the to-watch list.

  Future<void> removeFromToWatch(Movie movie) async {
    final toWatch = await getToWatch();
    toWatch.removeWhere((m) => m.id == movie.id);
    await _saveToWatch(toWatch);
    _toWatchController.add(toWatch);
  }

  /// Removes a movie from the watched list.

  Future<void> removeFromWatched(Movie movie) async {
    final watched = await getWatched();
    watched.removeWhere((m) => m.id == movie.id);
    await _saveWatched(watched);
    _watchedController.add(watched);
  }

  /// Checks if a movie is in the to-watch list.

  Future<bool> isInToWatch(Movie movie) async {
    final toWatch = await getToWatch();
    return toWatch.any((m) => m.id == movie.id);
  }

  /// Checks if a movie is in the watched list.

  Future<bool> isInWatched(Movie movie) async {
    final watched = await getWatched();
    return watched.any((m) => m.id == movie.id);
  }

  /// Saves the list of to-watch movies to shared preferences.

  Future<void> _saveToWatch(List<Movie> movies) async {
    final encoded = jsonEncode(movies.map((m) => m.toJson()).toList());
    await _prefs.setString(_toWatchKey, encoded);
  }

  /// Saves the list of watched movies to shared preferences.

  Future<void> _saveWatched(List<Movie> movies) async {
    final encoded = jsonEncode(movies.map((m) => m.toJson()).toList());
    await _prefs.setString(_watchedKey, encoded);
  }

  /// Disposes the stream controllers.

  void dispose() {
    _toWatchController.close();
    _watchedController.close();
  }
}
