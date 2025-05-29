/// Main home screen of the Movie Star application, displaying featured and trending movies.
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

import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:moviestar/models/movie.dart';
import 'package:moviestar/screens/movie_details_screen.dart';
import 'package:moviestar/screens/search_screen.dart';
import 'package:moviestar/services/favorites_service.dart';
import 'package:moviestar/services/movie_service.dart';

/// A screen that displays various movie categories and trending content.
class HomeScreen extends StatefulWidget {
  /// Service for managing favorite movies.

  final FavoritesService favoritesService;
  final MovieService movieService;

  /// Creates a new [HomeScreen] widget.

  const HomeScreen({
    super.key,
    required this.favoritesService,
    required this.movieService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// State class for the home screen.

class _HomeScreenState extends State<HomeScreen> {
  /// Loading state indicator.

  bool _isLoading = true;

  /// Error message if any.

  String? _error;

  /// List of popular movies.

  List<Movie> _popularMovies = [];

  /// List of now playing movies.

  List<Movie> _nowPlayingMovies = [];

  /// List of top rated movies.

  List<Movie> _topRatedMovies = [];

  /// List of upcoming movies.

  List<Movie> _upcomingMovies = [];

  /// Map of scroll controllers for different movie categories.

  final Map<String, ScrollController> _scrollControllers = {};

  @override
  void initState() {
    super.initState();
    _scrollControllers['popular'] = ScrollController();
    _scrollControllers['nowPlaying'] = ScrollController();
    _scrollControllers['topRated'] = ScrollController();
    _scrollControllers['upcoming'] = ScrollController();
    _loadAllMovies();
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if the movie service instance has changed or been updated.

    if (oldWidget.movieService != widget.movieService) {
      _loadAllMovies();
    }
  }

  @override
  void dispose() {
    for (var controller in _scrollControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Loads all movie categories.

  Future<void> _loadAllMovies() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final popular = await widget.movieService.getPopularMovies();
      final nowPlaying = await widget.movieService.getNowPlayingMovies();
      final topRated = await widget.movieService.getTopRatedMovies();
      final upcoming = await widget.movieService.getUpcomingMovies();

      setState(() {
        _popularMovies = popular;
        _nowPlayingMovies = nowPlaying;
        _topRatedMovies = topRated;
        _upcomingMovies = upcoming;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Builds a horizontal scrollable row of movies.

  Widget _buildMovieRow(String title, List<Movie> movies, String key) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: Scrollbar(
            controller: _scrollControllers[key],
            thickness: 6,
            radius: const Radius.circular(3),
            thumbVisibility: true,
            child: ListView.builder(
              controller: _scrollControllers[key],
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => MovieDetailsScreen(
                                movie: movie,
                                favoritesService: widget.favoritesService,
                              ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: CachedNetworkImage(
                        imageUrl: movie.posterUrl,
                        width: 130,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                        errorWidget:
                            (context, url, error) => const Icon(Icons.error),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'MOVIE STAR',
          style: TextStyle(
            color: Colors.red,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => SearchScreen(
                        favoritesService: widget.favoritesService,
                        movieService: widget.movieService,
                      ),
                ),
              );
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadAllMovies,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMovieRow(
                      'Popular on Movie Star',
                      _popularMovies,
                      'popular',
                    ),
                    _buildMovieRow(
                      'Now Playing',
                      _nowPlayingMovies,
                      'nowPlaying',
                    ),
                    _buildMovieRow('Top Rated', _topRatedMovies, 'topRated'),
                    _buildMovieRow('Upcoming', _upcomingMovies, 'upcoming'),
                  ],
                ),
              ),
    );
  }
}
