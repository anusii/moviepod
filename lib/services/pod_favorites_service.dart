/// POD-based service for managing favorite movies using Solid POD storage.
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
/// Authors: Ashley Tang

library;

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solidpod/solidpod.dart';

import 'package:moviestar/models/movie.dart';
import 'package:moviestar/services/favorites_service.dart';
import 'package:moviestar/utils/is_logged_in.dart';
import 'package:moviestar/utils/turtle_serializer.dart';

/// A POD-based service class that manages the user's movie lists in Solid POD.

class PodFavoritesService extends ChangeNotifier {
  /// File names for storing data in POD - using different paths for read vs write operations.

  static const String _toWatchFileName = 'user_lists/to_watch.ttl';
  static const String _watchedFileName = 'user_lists/watched.ttl';
  static const String _ratingsFileName = 'ratings/ratings.ttl';
  static const String _commentsFileName = 'user_lists/comments.ttl';

  // Full paths for reading operations (where files are actually stored).

  static const String _toWatchFileNameRead =
      'moviestar/data/user_lists/to_watch.ttl';
  static const String _watchedFileNameRead =
      'moviestar/data/user_lists/watched.ttl';
  static const String _ratingsFileNameRead =
      'moviestar/data/ratings/ratings.ttl';
  static const String _commentsFileNameRead =
      'moviestar/data/user_lists/comments.ttl';

  /// Widget context for POD operations.

  final BuildContext _context;

  /// Widget for returning after operations.

  final Widget _child;

  /// SharedPreferences for fallback storage.

  final SharedPreferences _prefs;

  /// Fallback favorites service for compatibility.

  final FavoritesService _fallbackService;

  /// Cache for movie data to avoid frequent POD reads.

  List<Movie>? _cachedToWatch;
  List<Movie>? _cachedWatched;
  Map<String, double>? _cachedRatings;
  Map<String, String>? _cachedComments;

  /// Track if we're currently syncing with POD.

  bool _isSyncing = false;

  /// Stream controller for to-watch movies.

  final _toWatchController = BehaviorSubject<List<Movie>>();

  /// Stream controller for watched movies.

  final _watchedController = BehaviorSubject<List<Movie>>();

  /// Stream of to-watch movies.

  Stream<List<Movie>> get toWatchMovies => _toWatchController.stream;

  /// Stream of watched movies.

  Stream<List<Movie>> get watchedMovies => _watchedController.stream;

  /// Creates a new [PodFavoritesService] instance.

  PodFavoritesService(this._prefs, this._context, this._child)
    : _fallbackService = FavoritesService(_prefs) {
    _initializePodData();
  }

  /// Initialize POD data by loading from POD if available.

  Future<void> _initializePodData() async {
    try {
      // Check if user is logged into POD first.

      final isPodReady = await isPodAvailable();
      if (isPodReady) {
        // Try to load from POD, but don't fail if folders aren't ready yet.

        await _loadFromPod();
        debugPrint('POD storage initialized successfully');
      } else {
        debugPrint(
          'POD not available, using empty data (files will be created when data is added)',
        );
        // Initialize with empty data for new POD storage.

        _cachedToWatch = [];
        _cachedWatched = [];
        _cachedRatings = {};
        _cachedComments = {};
        _toWatchController.add(_cachedToWatch!);
        _watchedController.add(_cachedWatched!);
      }
    } catch (e) {
      debugPrint('Failed to initialize POD data: $e');
      // Initialize with empty data.

      _cachedToWatch = [];
      _cachedWatched = [];
      _cachedRatings = {};
      _cachedComments = {};
      _toWatchController.add(_cachedToWatch!);
      _watchedController.add(_cachedWatched!);
    }
  }

  /// Loads data from POD and caches it locally.

  Future<void> _loadFromPod() async {
    _isSyncing = true;

    try {
      // Initialize with empty data first.

      _cachedToWatch = [];
      _cachedWatched = [];
      _cachedRatings = {};
      _cachedComments = {};

      // Try to load each file individually using full read paths, handling missing files gracefully.

      await _loadFileFromPod(_toWatchFileNameRead, (content) {
        if (content is String) {
          _cachedToWatch = TurtleSerializer.moviesFromTurtle(content);
          debugPrint(
            'Loaded ${_cachedToWatch!.length} movies from POD to-watch list',
          );
        }
      });

      await _loadFileFromPod(_watchedFileNameRead, (content) {
        if (content is String) {
          _cachedWatched = TurtleSerializer.moviesFromTurtle(content);
        }
      });

      await _loadFileFromPod(_ratingsFileNameRead, (content) {
        if (content is String) {
          _cachedRatings = TurtleSerializer.ratingsFromTurtle(content);
        }
      });

      await _loadFileFromPod(_commentsFileNameRead, (content) {
        if (content is String) {
          _cachedComments = TurtleSerializer.commentsFromTurtle(content);
        }
      });

      // Update streams with POD data.

      _toWatchController.add(_cachedToWatch!);
      _watchedController.add(_cachedWatched!);

      debugPrint('Successfully loaded data from POD');
    } catch (e) {
      debugPrint('Error loading from POD: $e');
      // Initialize with empty data if POD fails.

      _cachedToWatch = [];
      _cachedWatched = [];
      _cachedRatings = {};
      _cachedComments = {};
    } finally {
      _isSyncing = false;
    }
  }

  /// Helper method to load a single file from POD with error handling and retry mechanism.

  Future<void> _loadFileFromPod(
    String fileName,
    Function(dynamic) onSuccess,
  ) async {
    int retryCount = 0;
    const maxRetries = 3;
    const retryDelay = Duration(milliseconds: 200);

    while (retryCount < maxRetries) {
      try {
        debugPrint(
          'Attempting to load file from POD: $fileName (attempt ${retryCount + 1}/$maxRetries)',
        );

        // Debug: Check authentication status just before read
        final loggedIn = await isLoggedIn();
        debugPrint('Authentication status before read: $loggedIn');
        if (!loggedIn) {
          debugPrint('Not logged in to POD, skipping file load for $fileName');
          return;
        }

        // Ensure encryption key is available for reading.

        debugPrint(
          'Ensuring encryption key is available for reading $fileName',
        );
        if (!_context.mounted) return;

        await getKeyFromUserIfRequired(
          _context,
          const Text('Loading encryption key'),
        );
        debugPrint('Encryption key ready for reading');

        // Load file from POD using original widget context.

        debugPrint('Reading from POD path: $fileName');
        if (!_context.mounted) return;
        final content = await readPod(fileName, _context, _child);
        debugPrint(
          'ReadPod returned content type: ${content.runtimeType}, length: ${content.length}',
        );
        onSuccess(content);
        debugPrint('Successfully loaded $fileName from POD');
        return;
      } catch (e) {
        retryCount++;

        // Check if this is a "file not found" error.

        if (e.toString().contains('does not exist')) {
          debugPrint(
            'File $fileName does not exist in POD yet (this is normal for new storage)',
          );
          return;
        } else {
          debugPrint(
            'Error loading $fileName from POD (attempt $retryCount/$maxRetries): $e',
          );

          if (retryCount < maxRetries) {
            debugPrint('Retrying in ${retryDelay.inMilliseconds}ms...');
            await Future.delayed(retryDelay);
          } else {
            debugPrint('Max retries reached for $fileName');
          }
        }
      }
    }
  }

  /// Saves to-watch list to POD.

  Future<void> _saveToWatchToPod(List<Movie> movies) async {
    if (_isSyncing) return;

    try {
      // Ensure we're logged in before attempting to save.

      final loggedIn = await isLoggedIn();
      if (!loggedIn) {
        debugPrint('Not logged in to POD, falling back to SharedPreferences');
        final encoded = jsonEncode(movies.map((m) => m.toJson()).toList());
        await _prefs.setString('to_watch', encoded);
        return;
      }

      debugPrint(
        'Attempting to save ${movies.length} movies to POD: $_toWatchFileName',
      );
      final ttlContent = TurtleSerializer.moviesToTurtleWithJson(
        movies,
        'toWatchList',
      );
      debugPrint(
        'Generated TTL content length: ${ttlContent.length} characters',
      );

      // Debug: Check authentication status just before save.

      final authStatus = await isLoggedIn();
      debugPrint('Authentication status before save: $authStatus');

      // Ensure encryption key is available for writing.

      debugPrint(
        'Ensuring encryption key is available for saving $_toWatchFileName',
      );
      if (!_context.mounted) return;
      await getKeyFromUserIfRequired(
        _context,
        const Text('Loading encryption key'),
      );
      debugPrint('Encryption key ready for saving');

      debugPrint('Writing to POD path: $_toWatchFileName');
      if (!_context.mounted) return;
      final result = await writePod(
        _toWatchFileName,
        ttlContent,
        _context,
        _child,
      );
      debugPrint('WritePod result: $result');

      if (result == SolidFunctionCallStatus.success) {
        _cachedToWatch = List.from(movies);
        debugPrint('Successfully saved to-watch list to POD');

        // Add a small delay to allow POD to synchronize.

        await Future.delayed(const Duration(milliseconds: 500));
        debugPrint('POD sync delay completed for to-watch list');

        // Debug: Try to list what's in the user_lists directory after save.

        try {
          debugPrint('Checking POD directory contents after save...');
          final userListsUrl = await getDirUrl('user_lists');
          debugPrint('User lists directory URL: $userListsUrl');
          final resources = await getResourcesInContainer(userListsUrl);
          debugPrint(
            'Files in user_lists directory: ${resources.files.length}',
          );
          debugPrint(
            'Subdirs in user_lists directory: ${resources.subDirs.length}',
          );
          for (var file in resources.files) {
            debugPrint('  - File: $file');
          }
          for (var subDir in resources.subDirs) {
            debugPrint('  - SubDir: $subDir');
          }
        } catch (e) {
          debugPrint('Failed to list POD directory contents: $e');
        }
      } else {
        debugPrint('WritePod failed with status: $result');
        throw Exception('WritePod failed with status: $result');
      }
    } catch (e) {
      debugPrint('Failed to save to-watch list to POD: $e');
      // Fallback to SharedPreferences.

      final encoded = jsonEncode(movies.map((m) => m.toJson()).toList());
      await _prefs.setString('to_watch', encoded);
      debugPrint('Fell back to SharedPreferences for to-watch list');
    }
  }

  /// Saves watched list to POD.

  Future<void> _saveWatchedToPod(List<Movie> movies) async {
    if (_isSyncing) return;

    try {
      final ttlContent = TurtleSerializer.moviesToTurtleWithJson(
        movies,
        'watchedList',
      );
      await writePod(_watchedFileName, ttlContent, _context, _child);
      _cachedWatched = List.from(movies);
    } catch (e) {
      debugPrint('Failed to save watched list to POD: $e');

      // Fallback to SharedPreferences.

      final encoded = jsonEncode(movies.map((m) => m.toJson()).toList());
      await _prefs.setString('watched', encoded);
    }
  }

  /// Saves ratings to POD.

  Future<void> _saveRatingsToPod(Map<String, double> ratings) async {
    if (_isSyncing) return;

    try {
      final ttlContent = TurtleSerializer.ratingsToTurtleWithJson(ratings);
      await writePod(_ratingsFileName, ttlContent, _context, _child);
      _cachedRatings = Map.from(ratings);
    } catch (e) {
      debugPrint('Failed to save ratings to POD: $e');
    }
  }

  /// Saves comments to POD.

  Future<void> _saveCommentsToPod(Map<String, String> comments) async {
    if (_isSyncing) return;

    try {
      final ttlContent = TurtleSerializer.commentsToTurtleWithJson(comments);
      await writePod(_commentsFileName, ttlContent, _context, _child);
      _cachedComments = Map.from(comments);
    } catch (e) {
      debugPrint('Failed to save comments to POD: $e');
    }
  }

  /// Retrieves the list of to-watch movies from POD cache.

  Future<List<Movie>> getToWatch() async {
    if (_cachedToWatch != null) {
      return List.from(_cachedToWatch!);
    }

    // Fallback to SharedPreferences if cache is empty.

    return _fallbackService.getToWatch();
  }

  /// Retrieves the list of watched movies from POD cache.

  Future<List<Movie>> getWatched() async {
    if (_cachedWatched != null) {
      return List.from(_cachedWatched!);
    }

    // Fallback to SharedPreferences if cache is empty.

    return _fallbackService.getWatched();
  }

  /// Adds a movie to the to-watch list and saves to POD.

  Future<void> addToWatch(Movie movie) async {
    debugPrint('Adding movie to watch: ${movie.title} (ID: ${movie.id})');
    final toWatch = await getToWatch();
    debugPrint('Current to-watch list has ${toWatch.length} movies');

    if (!toWatch.any((m) => m.id == movie.id)) {
      toWatch.add(movie);
      debugPrint('Movie added, new list size: ${toWatch.length}');
      await _saveToWatchToPod(toWatch);
      _toWatchController.add(toWatch);
      debugPrint('Updated stream with ${toWatch.length} movies');
    } else {
      debugPrint('Movie already exists in to-watch list');
    }
  }

  /// Adds a movie to the watched list and saves to POD.

  Future<void> addToWatched(Movie movie) async {
    final watched = await getWatched();
    if (!watched.any((m) => m.id == movie.id)) {
      watched.add(movie);
      await _saveWatchedToPod(watched);
      _watchedController.add(watched);
    }
  }

  /// Removes a movie from the to-watch list and saves to POD.

  Future<void> removeFromToWatch(Movie movie) async {
    final toWatch = await getToWatch();
    toWatch.removeWhere((m) => m.id == movie.id);
    await _saveToWatchToPod(toWatch);
    _toWatchController.add(toWatch);
  }

  /// Removes a movie from the watched list and saves to POD.

  Future<void> removeFromWatched(Movie movie) async {
    final watched = await getWatched();
    watched.removeWhere((m) => m.id == movie.id);
    await _saveWatchedToPod(watched);
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

  /// Gets the user's personal rating for a movie from POD.

  Future<double?> getPersonalRating(Movie movie) async {
    if (_cachedRatings != null) {
      return _cachedRatings![movie.id.toString()];
    }

    // Fallback to SharedPreferences.

    return _fallbackService.getPersonalRating(movie);
  }

  /// Sets the user's personal rating for a movie and saves to POD.

  Future<void> setPersonalRating(Movie movie, double rating) async {
    final ratings = _cachedRatings ?? {};
    ratings[movie.id.toString()] = rating;
    await _saveRatingsToPod(ratings);
  }

  /// Removes the user's personal rating for a movie from POD.

  Future<void> removePersonalRating(Movie movie) async {
    final ratings = _cachedRatings ?? {};
    ratings.remove(movie.id.toString());
    await _saveRatingsToPod(ratings);
  }

  /// Gets the personal comments for a movie from POD.

  Future<String?> getMovieComments(Movie movie) async {
    if (_cachedComments != null) {
      return _cachedComments![movie.id.toString()];
    }

    // Fallback to SharedPreferences.

    return _fallbackService.getMovieComments(movie);
  }

  /// Sets the personal comments for a movie and saves to POD.

  Future<void> setMovieComments(Movie movie, String comments) async {
    final commentsMap = _cachedComments ?? {};
    commentsMap[movie.id.toString()] = comments;
    await _saveCommentsToPod(commentsMap);
    notifyListeners();
  }

  /// Removes the personal comments for a movie from POD.

  Future<void> removeMovieComments(Movie movie) async {
    final comments = _cachedComments ?? {};
    comments.remove(movie.id.toString());
    await _saveCommentsToPod(comments);
    notifyListeners();
  }

  /// Migrates data from SharedPreferences to POD.

  Future<void> migrateToPod() async {
    try {
      // Load data from SharedPreferences.

      final toWatch = await _fallbackService.getToWatch();
      final watched = await _fallbackService.getWatched();

      // Migrate ratings.

      final Map<String, double> ratings = {};
      for (final movie in [...toWatch, ...watched]) {
        final rating = await _fallbackService.getPersonalRating(movie);
        if (rating != null) {
          ratings[movie.id.toString()] = rating;
        }
      }

      // Migrate comments.

      final Map<String, String> comments = {};
      for (final movie in [...toWatch, ...watched]) {
        final comment = await _fallbackService.getMovieComments(movie);
        if (comment != null) {
          comments[movie.id.toString()] = comment;
        }
      }

      // Save to POD.

      await _saveToWatchToPod(toWatch);
      await _saveWatchedToPod(watched);
      await _saveRatingsToPod(ratings);
      await _saveCommentsToPod(comments);

      debugPrint('Successfully migrated data to POD');
    } catch (e) {
      debugPrint('Failed to migrate data to POD: $e');
      rethrow;
    }
  }

  /// Syncs data between POD and local cache.

  Future<void> syncWithPod() async {
    await _loadFromPod();
  }

  /// Reloads data from POD after app folders are initialized.

  Future<void> reloadFromPod() async {
    try {
      final isPodReady = await isPodAvailable();
      if (isPodReady) {
        debugPrint(
          'Reloading data from POD after app folders initialization...',
        );
        await _loadFromPod();
        debugPrint('Successfully reloaded data from POD');
      }
    } catch (e) {
      debugPrint('Failed to reload from POD: $e');
    }
  }

  /// Checks if POD storage is available and user is logged in.

  Future<bool> isPodAvailable() async {
    try {
      // Import the isLoggedIn function to check POD login status.
      // This is better than trying to read a non-existent file.

      final loggedIn = await isLoggedIn();
      return loggedIn;
    } catch (e) {
      debugPrint('POD availability check failed: $e');
      return false;
    }
  }

  /// Disposes the stream controllers.

  @override
  void dispose() {
    super.dispose();
    _toWatchController.close();
    _watchedController.close();
    _fallbackService.dispose();
  }
}
