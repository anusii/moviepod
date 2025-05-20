/// Utility class for handling TMDB image URLs.
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

/// A utility class for handling TMDB image URLs.
class TmdbImageUtil {
  /// Base URL for TMDB images.
  static const String _baseUrl = 'https://image.tmdb.org/t/p';

  /// Available image sizes for posters.
  static const Map<String, String> posterSizes = {
    'w92': 'w92',
    'w154': 'w154',
    'w185': 'w185',
    'w342': 'w342',
    'w500': 'w500',
    'w780': 'w780',
    'original': 'original',
  };

  /// Available image sizes for backdrops.
  static const Map<String, String> backdropSizes = {
    'w300': 'w300',
    'w780': 'w780',
    'w1280': 'w1280',
    'original': 'original',
  };

  /// Available image sizes for profile pictures.
  static const Map<String, String> profileSizes = {
    'w45': 'w45',
    'w185': 'w185',
    'h632': 'h632',
    'original': 'original',
  };

  /// Creates a poster URL with the specified size.
  static String getPosterUrl(String path, {String size = 'w500'}) {
    if (path.isEmpty) return '';
    return '$_baseUrl/${posterSizes[size] ?? posterSizes['w500']!}$path';
  }

  /// Creates a backdrop URL with the specified size.
  static String getBackdropUrl(String path, {String size = 'original'}) {
    if (path.isEmpty) return '';
    return '$_baseUrl/${backdropSizes[size] ?? backdropSizes['original']!}$path';
  }

  /// Creates a profile picture URL with the specified size.
  static String getProfileUrl(String path, {String size = 'w185'}) {
    if (path.isEmpty) return '';
    return '$_baseUrl/${profileSizes[size] ?? profileSizes['w185']!}$path';
  }

  /// Extracts the path from a full TMDB image URL.
  static String extractPath(String url) {
    if (url.isEmpty) return '';
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    if (pathSegments.length < 2) return '';
    return '/${pathSegments.sublist(1).join('/')}';
  }
}
