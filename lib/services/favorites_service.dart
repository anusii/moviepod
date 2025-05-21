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

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/rxdart.dart';
import '../models/movie.dart';

/// A service class that manages the user's favorite movies.

class FavoritesService {
  /// Key used to store favorites in shared preferences.

  static const String _favoritesKey = 'favorites';

  /// Shared preferences instance for storing favorites。

  final SharedPreferences _prefs;

  /// Stream controller for favorite movies.
  final _favoritesController = BehaviorSubject<List<Movie>>();

  /// Stream of favorite movies.
  Stream<List<Movie>> get favoriteMovies => _favoritesController.stream;

  /// Creates a new [FavoritesService] instance.
  FavoritesService(this._prefs) {
    _loadFavorites();
  }

  /// Loads favorites and emits them to the stream.
  Future<void> _loadFavorites() async {
    final favorites = await getFavorites();
    _favoritesController.add(favorites);
  }

  /// Retrieves the list of favorite movies.

  Future<List<Movie>> getFavorites() async {
    final String? favoritesJson = _prefs.getString(_favoritesKey);
    if (favoritesJson == null) return [];

    final List<dynamic> decoded = jsonDecode(favoritesJson);
    return decoded.map((movie) => Movie.fromJson(movie)).toList();
  }

  /// Adds a movie to the favorites list.

  Future<void> addToFavorites(Movie movie) async {
    final favorites = await getFavorites();
    if (!favorites.any((m) => m.id == movie.id)) {
      favorites.add(movie);
      await _saveFavorites(favorites);
      _favoritesController.add(favorites);
    }
  }

  /// Removes a movie from the favorites list.

  Future<void> removeFromFavorites(Movie movie) async {
    final favorites = await getFavorites();
    favorites.removeWhere((m) => m.id == movie.id);
    await _saveFavorites(favorites);
    _favoritesController.add(favorites);
  }

  /// Alias for removeFromFavorites for consistency.
  Future<void> removeFavorite(Movie movie) => removeFromFavorites(movie);

  /// Checks if a movie is in the favorites list.

  Future<bool> isFavorite(Movie movie) async {
    final favorites = await getFavorites();
    return favorites.any((m) => m.id == movie.id);
  }

  /// Saves the list of favorite movies to shared preferences.

  Future<void> _saveFavorites(List<Movie> favorites) async {
    final encoded = jsonEncode(favorites.map((m) => m.toJson()).toList());
    await _prefs.setString(_favoritesKey, encoded);
  }

  /// Disposes the stream controller.
  void dispose() {
    _favoritesController.close();
  }
}
