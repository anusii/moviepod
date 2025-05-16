/// Screen displaying the user's list of favorite movies.
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
import 'movie_details_screen.dart';

class MyListScreen extends StatefulWidget {
  final FavoritesService favoritesService;

  const MyListScreen({super.key, required this.favoritesService});

  @override
  State<MyListScreen> createState() => _MyListScreenState();
}

class _MyListScreenState extends State<MyListScreen> {
  List<Movie> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    final favorites = await widget.favoritesService.getFavorites();
    setState(() {
      _favorites = favorites;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('My List', style: TextStyle(color: Colors.white)),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _favorites.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.favorite_border,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your list is empty',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add movies to your list to watch them later',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              )
              : GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _favorites.length,
                itemBuilder: (context, index) {
                  final movie = _favorites[index];
                  return GestureDetector(
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
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: CachedNetworkImage(
                            imageUrl: movie.posterUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: IconButton(
                            icon: const Icon(Icons.favorite, color: Colors.red),
                            onPressed: () async {
                              await widget.favoritesService.removeFromFavorites(
                                movie,
                              );
                              _loadFavorites();
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
