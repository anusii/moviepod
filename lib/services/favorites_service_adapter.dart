/// Adapter to make FavoritesServiceManager compatible with existing screens.
///
// Copyright (C) 2025, Software Innovation Institute, ANU.
//
// Licensed under the GNU General Public License, Version 3 (the "License").
//
// License: https://www.gnu.org/licenses/gpl-3.0.en.html.

library;



import 'package:moviestar/models/movie.dart';
import 'package:moviestar/services/favorites_service.dart';
import 'package:moviestar/services/favorites_service_manager.dart';

/// Adapter that makes FavoritesServiceManager look like FavoritesService.
/// This allows us to integrate POD storage without changing all existing screens.
class FavoritesServiceAdapter extends FavoritesService {
  final FavoritesServiceManager _manager;

  FavoritesServiceAdapter(this._manager) : super(_manager.prefs);

  @override
  Stream<List<Movie>> get toWatchMovies => _manager.toWatchMovies;

  @override
  Stream<List<Movie>> get watchedMovies => _manager.watchedMovies;

  @override
  Future<List<Movie>> getToWatch() => _manager.getToWatch();

  @override
  Future<List<Movie>> getWatched() => _manager.getWatched();

  @override
  Future<void> addToWatch(Movie movie) => _manager.addToWatch(movie);

  @override
  Future<void> addToWatched(Movie movie) => _manager.addToWatched(movie);

  @override
  Future<void> removeFromToWatch(Movie movie) => _manager.removeFromToWatch(movie);

  @override
  Future<void> removeFromWatched(Movie movie) => _manager.removeFromWatched(movie);

  @override
  Future<bool> isInToWatch(Movie movie) => _manager.isInToWatch(movie);

  @override
  Future<bool> isInWatched(Movie movie) => _manager.isInWatched(movie);

  @override
  Future<double?> getPersonalRating(Movie movie) => _manager.getPersonalRating(movie);

  @override
  Future<void> setPersonalRating(Movie movie, double rating) => _manager.setPersonalRating(movie, rating);

  @override
  Future<void> removePersonalRating(Movie movie) => _manager.removePersonalRating(movie);

  @override
  Future<String?> getMovieComments(Movie movie) => _manager.getMovieComments(movie);

  @override
  Future<void> setMovieComments(Movie movie, String comments) => _manager.setMovieComments(movie, comments);

  @override
  Future<void> removeMovieComments(Movie movie) => _manager.removeMovieComments(movie);

  @override
  void dispose() {
    // Don't dispose the manager as other components may still be using it
    super.dispose();
  }
} 