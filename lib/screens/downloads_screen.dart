/// Screen for managing downloaded movies and offline content.
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
import '../models/movie.dart';

/// A screen that displays and manages downloaded movies.
class DownloadsScreen extends StatefulWidget {
  /// Creates a new [DownloadsScreen] widget.
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

/// State class for the downloads screen.
class _DownloadsScreenState extends State<DownloadsScreen> {
  /// List of downloaded movies.
  final List<Movie> _downloadedMovies = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Downloads', style: TextStyle(color: Colors.white)),
      ),
      body:
          _downloadedMovies.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.download_done,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Movies you download appear here',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement find movies to download
                      },
                      icon: const Icon(Icons.search),
                      label: const Text('Find Movies to Download'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: _downloadedMovies.length,
                itemBuilder: (context, index) {
                  final movie = _downloadedMovies[index];
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        movie.posterUrl,
                        width: 60,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      movie.title,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      '${movie.releaseDate.year}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        // TODO: Implement delete functionality
                      },
                    ),
                  );
                },
              ),
    );
  }
}
