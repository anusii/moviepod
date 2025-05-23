/// Screen displaying detailed information about a selected movie.
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

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie.dart';
import '../services/favorites_service.dart';
import '../utils/date_format_util.dart';

/// A screen that displays detailed information about a selected movie.

class MovieDetailsScreen extends StatefulWidget {
  /// The movie to display details for.

  final Movie movie;

  /// Service for managing favorite movies.

  final FavoritesService favoritesService;

  /// Creates a new [MovieDetailsScreen] widget.

  const MovieDetailsScreen({
    super.key,
    required this.movie,
    required this.favoritesService,
  });

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

/// State class for the movie details screen.

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  /// Indicates whether the movie is in the to-watch list.

  bool _isInToWatch = false;

  /// Indicates whether the movie is in the watched list.

  bool _isInWatched = false;

  /// Personal rating for the movie.
  double? _personalRating;

  /// Indicates whether the personal rating is being loaded.
  bool _isLoadingRating = true;

  @override
  void initState() {
    super.initState();
    _checkListStatus();
    _loadPersonalRating();
  }

  /// Checks if the current movie is in either list.

  Future<void> _checkListStatus() async {
    final isInToWatch = await widget.favoritesService.isInToWatch(widget.movie);
    final isInWatched = await widget.favoritesService.isInWatched(widget.movie);
    setState(() {
      _isInToWatch = isInToWatch;
      _isInWatched = isInWatched;
    });
  }

  /// Toggles the to-watch status of the current movie.

  Future<void> _toggleToWatch() async {
    if (_isInToWatch) {
      await widget.favoritesService.removeFromToWatch(widget.movie);
    } else {
      await widget.favoritesService.addToWatch(widget.movie);
    }
    setState(() {
      _isInToWatch = !_isInToWatch;
    });
  }

  /// Toggles the watched status of the current movie.

  Future<void> _toggleWatched() async {
    if (_isInWatched) {
      await widget.favoritesService.removeFromWatched(widget.movie);
    } else {
      await widget.favoritesService.addToWatched(widget.movie);
    }
    setState(() {
      _isInWatched = !_isInWatched;
    });
  }

  Future<void> _loadPersonalRating() async {
    final rating = await widget.favoritesService.getPersonalRating(
      widget.movie,
    );
    setState(() {
      _personalRating = rating;
      _isLoadingRating = false;
    });
  }

  Future<void> _updateRating(double? rating) async {
    if (rating == null) {
      await widget.favoritesService.removePersonalRating(widget.movie);
    } else {
      await widget.favoritesService.setPersonalRating(widget.movie, rating);
    }
    setState(() {
      _personalRating = rating;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: widget.movie.backdropUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.movie.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              _isInToWatch
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: _isInToWatch ? Colors.blue : Colors.white,
                            ),
                            onPressed: _toggleToWatch,
                            tooltip: _isInToWatch
                                ? 'Remove from To Watch'
                                : 'Add to To Watch',
                          ),
                          IconButton(
                            icon: Icon(
                              _isInWatched
                                  ? Icons.check_circle
                                  : Icons.check_circle_outline,
                              color: _isInWatched ? Colors.green : Colors.white,
                            ),
                            onPressed: _toggleWatched,
                            tooltip: _isInWatched
                                ? 'Remove from Watched'
                                : 'Add to Watched',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        widget.movie.voteAverage.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormatUtil.formatShort(widget.movie.releaseDate),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Personal Rating Section
                  const Text(
                    'Your Rating',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _isLoadingRating
                      ? const Center(child: CircularProgressIndicator())
                      : Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: _personalRating ?? 0,
                              min: 0,
                              max: 10,
                              divisions: 10,
                              label: _personalRating?.toStringAsFixed(1) ?? '0',
                              onChanged: (value) => _updateRating(value),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white),
                            onPressed:
                                _personalRating == null
                                    ? null
                                    : () => _updateRating(null),
                            tooltip: 'Clear rating',
                          ),
                        ],
                      ),
                  Text(
                    _personalRating == null
                        ? 'No rating yet'
                        : 'Your rating: ${_personalRating!.toStringAsFixed(1)}/10',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Overview',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.movie.overview,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
